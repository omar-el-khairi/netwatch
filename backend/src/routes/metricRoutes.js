const express = require('express');
const {
  ingestMetric,
  getMetricsHistory,
} = require('../controllers/metricController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

// Agents push metrics with API key (no JWT)
router.post('/', ingestMetric);
// Dashboard needs JWT
router.get('/:serverId', authRequired, getMetricsHistory);

module.exports = router;
