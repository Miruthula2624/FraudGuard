const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const db = require('../config/db');

// Get user history
router.get('/', auth, async (req, res) => {
    try {
        const [rows] = await db.execute(
            'SELECT * FROM job_history WHERE user_id = ? ORDER BY created_at DESC',
            [req.session.userId]
        );

        // Parse results
        const history = rows.map(row => ({
            ...row,
            scam_indicators: JSON.parse(row.scam_indicators || '[]')
        }));

        res.json(history);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Error fetching history' });
    }
});

// Delete history item
router.delete('/:id', auth, async (req, res) => {
    try {
        await db.execute(
            'DELETE FROM job_history WHERE id = ? AND user_id = ?',
            [req.params.id, req.session.userId]
        );
        res.json({ message: 'History item deleted' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Error deleting history item' });
    }
});

module.exports = router;
