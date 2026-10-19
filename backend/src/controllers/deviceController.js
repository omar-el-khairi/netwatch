const { registerDevice, listDevices } = require('../services/pushService');

async function register(req, res, next) {
  try {
    const { token, platform } = req.body;
    const device = await registerDevice({
      token,
      platform,
      userId: req.user?.sub,
    });
    return res.status(201).json(device);
  } catch (err) {
    return next(err);
  }
}

async function list(req, res, next) {
  try {
    const devices = await listDevices();
    return res.json(devices);
  } catch (err) {
    return next(err);
  }
}

module.exports = { register, list };
