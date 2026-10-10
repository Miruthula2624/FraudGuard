const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const db = require('../config/db');

// Helper to safely parse indicators across multiple formats (JSON string, Array, plain text)
function parseIndicators(raw) {
    if (!raw) return [];
    if (Array.isArray(raw)) return raw;
    if (typeof raw === 'object') return [raw];
    if (typeof raw === 'string') {
        const trimmed = raw.trim();
        if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
            try {
                const parsed = JSON.parse(trimmed);
                return Array.isArray(parsed) ? parsed : [parsed];
            } catch (_) {
                return [raw];
            }
        }
        return [raw];
    }
    return [String(raw)];
}

// Get user history
router.get('/', auth, async (req, res) => {
    try {
        const userId = req.user?.id || req.user?.userId || req.session?.userId;
        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized. User ID not found.' });
        }

        const [rows] = await db.execute(
            'SELECT * FROM job_history WHERE user_id = ? ORDER BY created_at DESC',
            [userId]
        );

        // Parse results safely
        const history = rows.map(row => ({
            ...row,
            scam_indicators: parseIndicators(row.scam_indicators)
        }));

        res.json(history);
    } catch (err) {
        console.error('Error fetching history:', err);
        res.status(500).json({ message: 'Error fetching history', error: err.message });
    }
});

// Delete history item
router.delete('/:id', auth, async (req, res) => {
    try {
        const userId = req.user?.id || req.user?.userId || req.session?.userId;
        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized. User ID not found.' });
        }

        await db.execute(
            'DELETE FROM job_history WHERE id = ? AND user_id = ?',
            [req.params.id, userId]
        );
        res.json({ message: 'History item deleted' });
    } catch (err) {
        console.error('Error deleting history item:', err);
        res.status(500).json({ message: 'Error deleting history item', error: err.message });
    }
});

module.exports = router;

