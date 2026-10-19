const express = require('express');
const {
  listThresholds,
  upsertThreshold,
} = require('../controllers/thresholdController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.use(authRequired);
router.get('/', listThresholds);
router.post('/', upsertThreshold);

module.exports = router;
