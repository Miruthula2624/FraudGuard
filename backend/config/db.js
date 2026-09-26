require('dotenv').config();
const mysql = require('mysql2');

const poolConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'job_scam_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

// Enable TLS/SSL for cloud database providers (e.g., Aiven)
if (
    process.env.DB_SSL === 'true' ||
    process.env.DB_SSL === 'REQUIRED' ||
    process.env.DB_SSL === 'require' ||
    (process.env.DB_HOST && process.env.DB_HOST.includes('aivencloud.com'))
) {
    poolConfig.ssl = { rejectUnauthorized: false };
}

const pool = mysql.createPool(poolConfig);

module.exports = pool.promise();
