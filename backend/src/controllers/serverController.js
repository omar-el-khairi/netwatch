const crypto = require('crypto');
const prisma = require('../config/db');

async function listServers(req, res, next) {
  try {
    const servers = await prisma.server.findMany({
      orderBy: { name: 'asc' },
      include: {
        metrics: { orderBy: { collectedAt: 'desc' }, take: 1 },
        alerts: {
          where: { acknowledged: false },
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
      },
    });

    const payload = servers.map((s) => ({
      ...s,
      latestMetric: s.metrics[0] || null,
      metrics: undefined,
      openAlerts: s.alerts,
      alerts: undefined,
    }));

    return res.json(payload);
  } catch (err) {
    return next(err);
  }
}

async function getServer(req, res, next) {
  try {
    const server = await prisma.server.findUnique({
      where: { id: req.params.id },
      include: {
        thresholds: true,
        alerts: { orderBy: { createdAt: 'desc' }, take: 20 },
      },
    });
    if (!server) return res.status(404).json({ error: 'Serveur introuvable' });

    const latestMetric = await prisma.metric.findFirst({
      where: { serverId: server.id },
      orderBy: { collectedAt: 'desc' },
    });

    return res.json({ ...server, latestMetric });
  } catch (err) {
    return next(err);
  }
}

async function createServer(req, res, next) {
  try {
    const { name, hostname, ipAddress, osType } = req.body;
    if (!name || !hostname || !ipAddress || !osType) {
      return res.status(400).json({
        error: 'name, hostname, ipAddress et osType sont requis',
      });
    }

    const apiKey = crypto.randomBytes(24).toString('hex');
    const server = await prisma.server.create({
      data: {
        name,
        hostname,
        ipAddress,
        osType: String(osType).toLowerCase(),
        apiKey,
        status: 'pending',
      },
    });

    return res.status(201).json(server);
  } catch (err) {
    return next(err);
  }
}

async function updateServer(req, res, next) {
  try {
    const { name, hostname, ipAddress, osType } = req.body;
    const server = await prisma.server.update({
      where: { id: req.params.id },
      data: {
        ...(name !== undefined && { name }),
        ...(hostname !== undefined && { hostname }),
        ...(ipAddress !== undefined && { ipAddress }),
        ...(osType !== undefined && { osType: String(osType).toLowerCase() }),
      },
    });
    return res.json(server);
  } catch (err) {
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Serveur introuvable' });
    }
    return next(err);
  }
}

async function deleteServer(req, res, next) {
  try {
    await prisma.server.delete({ where: { id: req.params.id } });
    return res.status(204).send();
  } catch (err) {
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Serveur introuvable' });
    }
    return next(err);
  }
}

async function regenerateApiKey(req, res, next) {
  try {
    const apiKey = crypto.randomBytes(24).toString('hex');
    const server = await prisma.server.update({
      where: { id: req.params.id },
      data: { apiKey },
    });
    return res.json({ id: server.id, apiKey: server.apiKey });
  } catch (err) {
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Serveur introuvable' });
    }
    return next(err);
  }
}

module.exports = {
  listServers,
  getServer,
  createServer,
  updateServer,
  deleteServer,
  regenerateApiKey,
};
