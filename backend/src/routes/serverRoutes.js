const express = require('express');
const {
  listServers,
  getServer,
  createServer,
  updateServer,
  deleteServer,
  regenerateApiKey,
} = require('../controllers/serverController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.use(authRequired);
router.get('/', listServers);
router.get('/:id', getServer);
router.post('/', createServer);
router.put('/:id', updateServer);
router.delete('/:id', deleteServer);
router.post('/:id/regenerate-key', regenerateApiKey);

module.exports = router;
