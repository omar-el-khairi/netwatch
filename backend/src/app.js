const express = require('express');
const cors = require('cors');
const config = require('./config/env');
const { errorHandler } = require('./middleware/errorHandler');

const authRoutes = require('./routes/authRoutes');
const serverRoutes = require('./routes/serverRoutes');
const metricRoutes = require('./routes/metricRoutes');
const alertRoutes = require('./routes/alertRoutes');
const thresholdRoutes = require('./routes/thresholdRoutes');
const deviceRoutes = require('./routes/deviceRoutes');

function createApp() {
  const app = express();

  app.use(
    cors({
      origin: (origin, callback) => {
        if (!origin || config.corsOrigins.includes(origin) || config.corsOrigins.includes('*')) {
          return callback(null, true);
        }
        // Allow LAN origins for mobile / VM demos
        if (/^http:\/\/(localhost|127\.0\.0\.1|192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+)(:\d+)?$/.test(origin)) {
          return callback(null, true);
        }
        return callback(null, true);
      },
      credentials: true,
    })
  );
  app.use(express.json({ limit: '1mb' }));

  app.get('/api/health', (req, res) => {
    res.json({
      ok: true,
      service: 'supervision-backend',
      time: new Date().toISOString(),
    });
  });

  app.use('/api/auth', authRoutes);
  app.use('/api/servers', serverRoutes);
  app.use('/api/metrics', metricRoutes);
  app.use('/api/alerts', alertRoutes);
  app.use('/api/thresholds', thresholdRoutes);
  app.use('/api/devices', deviceRoutes);

  app.use(errorHandler);
  return app;
}

module.exports = { createApp };
