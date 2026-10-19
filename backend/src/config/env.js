require('dotenv').config();

const parseOrigins = (value) =>
  (value || 'http://localhost:5173')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

module.exports = {
  port: Number(process.env.PORT) || 4000,
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',
  corsOrigins: parseOrigins(process.env.CORS_ORIGIN),
  heartbeatTimeoutSeconds: Number(process.env.HEARTBEAT_TIMEOUT_SECONDS) || 30,
  heartbeatCheckIntervalSeconds:
    Number(process.env.HEARTBEAT_CHECK_INTERVAL_SECONDS) || 10,
};
