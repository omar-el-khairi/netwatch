const express = require('express');
const {
  listAlerts,
  acknowledgeAlert,
  exportAlerts,
} = require('../controllers/alertController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.use(authRequired);
router.get('/export', exportAlerts);
router.get('/', listAlerts);
router.post('/:id/acknowledge', acknowledgeAlert);

module.exports = router;
