const prisma = require('../config/db');
const config = require('../config/env');
const { evaluateMetrics } = require('../services/thresholdService');

async function ingestMetric(req, res, next) {
  try {
    const apiKey =
      req.headers['x-api-key'] || req.body.apiKey || req.query.apiKey;

    if (!apiKey) {
      return res.status(401).json({ error: 'API key agent manquante' });
    }

    const server = await prisma.server.findUnique({ where: { apiKey } });
    if (!server) {
      return res.status(401).json({ error: 'API key invalide' });
    }

    const {
      cpuPercent,
      ramPercent,
      diskPercent,
      pingMs,
      uptimeSeconds,
      services,
      collectedAt,
    } = req.body;

    if (
      cpuPercent === undefined ||
      ramPercent === undefined ||
      diskPercent === undefined
    ) {
      return res.status(400).json({
        error: 'cpuPercent, ramPercent et diskPercent sont requis',
      });
    }

    const metric = await prisma.metric.create({
      data: {
        serverId: server.id,
        cpuPercent: Number(cpuPercent),
        ramPercent: Number(ramPercent),
        diskPercent: Number(diskPercent),
        pingMs: pingMs !== undefined ? Number(pingMs) : null,
        uptimeSeconds: Number(uptimeSeconds) || 0,
        servicesJson: JSON.stringify(services || []),
        collectedAt: collectedAt ? new Date(collectedAt) : new Date(),
      },
    });

    const io = req.app.get('io');
    const { status } = await evaluateMetrics(server, metric, io);

    const updated = await prisma.server.update({
      where: { id: server.id },
      data: {
        status,
        lastSeenAt: new Date(),
      },
    });

    if (io) {
      io.emit('metric:new', { serverId: server.id, metric });
      io.emit('server:update', { ...updated, latestMetric: metric });
    }

    return res.status(201).json({
      ok: true,
      metricId: metric.id,
      status: updated.status,
    });
  } catch (err) {
    return next(err);
  }
}

async function getMetricsHistory(req, res, next) {
  try {
    const { serverId } = req.params;
    const limit = Math.min(Number(req.query.limit) || 100, 500);
    const sinceMinutes = Number(req.query.sinceMinutes) || 60;
    const since = new Date(Date.now() - sinceMinutes * 60 * 1000);

    const metrics = await prisma.metric.findMany({
      where: {
        serverId,
        collectedAt: { gte: since },
      },
      orderBy: { collectedAt: 'asc' },
      take: limit,
    });

    return res.json(metrics);
  } catch (err) {
    return next(err);
  }
}

module.exports = { ingestMetric, getMetricsHistory, config };
