const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const getJwtSecret = () => {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        if (process.env.NODE_ENV === 'production') {
            throw new Error('FATAL: JWT_SECRET environment variable is required in production.');
        }
        console.warn('⚠️ WARNING: JWT_SECRET not configured. Using fallback dev secret.');
        return 'dev_fallback_jwt_secret_do_not_use_in_prod';
    }
    return secret;
};

// Register
router.post('/register', async (req, res) => {
    try {
        const { fullname, email, password } = req.body;
        if (!fullname || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const [existingUser] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUser.length > 0) {
            return res.status(400).json({ message: 'Email already registered' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        await db.execute(
            'INSERT INTO users (fullname, email, password) VALUES (?, ?, ?)',
            [fullname, email, hashedPassword]
        );

        res.status(201).json({ message: 'Registration successful' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error during registration' });
    }
});

// Login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const user = users[0];
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Set session
        req.session.userId = user.id;
        req.session.username = user.fullname;

        // Generate JWT token for mobile clients
        const token = jwt.sign(
            { id: user.id, username: user.fullname },
            getJwtSecret(),
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login successful',
            user: { id: user.id, username: user.fullname, email: user.email },
            token
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error during login' });
    }
});

// Logout
router.post('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) {
            return res.status(500).json({ message: 'Could not log out' });
        }
        res.clearCookie('connect.sid');
        res.json({ message: 'Logout successful' });
    });
});

// Check Session
router.get('/check-session', (req, res) => {
    if (req.session.userId) {
        res.json({ loggedIn: true, user: { id: req.session.userId, username: req.session.username } });
    } else {
        res.json({ loggedIn: false });
    }
});

module.exports = router;
