const express = require('express');
const { register, list } = require('../controllers/deviceController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.use(authRequired);
router.post('/', register);
router.get('/', list);

module.exports = router;
