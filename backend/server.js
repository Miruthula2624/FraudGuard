require('dotenv').config();
const express = require('express');
const cors = require('cors');
const session = require('express-session');
const FileStore = require('session-file-store')(session);
const path = require('path');
const fs = require('fs');

const authRoutes = require('./routes/auth');
const scanRoutes = require('./routes/scan');
const historyRoutes = require('./routes/history');

const app = express();
const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

// Middleware
const allowedOrigins = [
    'http://localhost:5173',
    'http://127.0.0.1:5173'
];

app.use(cors({
    origin: (origin, callback) => {
        // Allow requests with no origin (e.g., native mobile apps, Postman, curl)
        if (!origin) return callback(null, true);

        // Allow configured web client origins
        if (allowedOrigins.indexOf(origin) !== -1) {
            return callback(null, true);
        }

        // In development mode, allow local network/emulator origins
        if (process.env.NODE_ENV !== 'production') {
            return callback(null, true);
        }

        callback(new Error('Blocked by CORS'));
    },
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}
app.use('/uploads', express.static(uploadsDir));

// Session configuration
app.use(session({
    store: new FileStore({ path: './sessions' }),
    secret: process.env.SESSION_SECRET || 'secret_scam_detector',
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: process.env.NODE_ENV === 'production', // true in production (HTTPS), false locally
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
}));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/scan', scanRoutes);
app.use('/api/history', historyRoutes);

// Base route
app.get('/', (req, res) => {
    res.send('Job Scam Detection API is running...');
});

app.listen(PORT, HOST, () => {
    console.log(`Server running on http://${HOST}:${PORT} (Port ${PORT})`);
});
