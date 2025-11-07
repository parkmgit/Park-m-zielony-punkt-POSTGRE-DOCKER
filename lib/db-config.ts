// Database configuration wrapper
// Always uses PostgreSQL (standard pg library)

console.log('🐘 Using PostgreSQL database');

export { query, queryOne, initDB, testConnection, closeConnection } from './db';
