const jwt = require('jsonwebtoken');

const getJwtSecret = () => {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        if (process.env.NODE_ENV === 'production') {
            throw new Error('FATAL: JWT_SECRET environment variable is required in production.');
        }
        return 'dev_fallback_jwt_secret_do_not_use_in_prod';
    }
    return secret;
};

const authMiddleware = (req, res, next) => {
    // Priority 1: Check for JWT Bearer token (Mobile / API clients)
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.substring(7).trim();
        try {
            const decoded = jwt.verify(token, getJwtSecret());
            req.user = decoded;
            // Ensure req.session has userId for compatibility with existing route queries
            req.session = req.session || {};
            req.session.userId = decoded.id;
            req.session.username = decoded.username;
            return next();
        } catch (err) {
            return res.status(401).json({ message: 'Invalid or expired token. Please log in again.' });
        }
    }

    // Priority 2: Fall back to cookie-session authentication (React Web client)
    if (req.session && req.session.userId) {
        return next();
    }

    // Neither authentication method satisfied
    return res.status(401).json({ message: 'Unauthorized. Please log in.' });
};

module.exports = authMiddleware;
