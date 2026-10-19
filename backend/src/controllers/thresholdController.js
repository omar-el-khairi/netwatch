const prisma = require('../config/db');
const { DEFAULTS } = require('../services/thresholdService');

async function listThresholds(req, res, next) {
  try {
    const rows = await prisma.threshold.findMany({
      orderBy: [{ serverId: 'asc' }, { metricType: 'asc' }],
    });

    return res.json({
      defaults: DEFAULTS,
      items: rows,
    });
  } catch (err) {
    return next(err);
  }
}

async function upsertThreshold(req, res, next) {
  try {
    const { metricType, warning, critical, serverId } = req.body;
    if (!metricType || warning === undefined || critical === undefined) {
      return res.status(400).json({
        error: 'metricType, warning et critical sont requis',
      });
    }

    const existing = await prisma.threshold.findFirst({
      where: {
        metricType,
        serverId: serverId || null,
      },
    });

    let row;
    if (existing) {
      row = await prisma.threshold.update({
        where: { id: existing.id },
        data: {
          warning: Number(warning),
          critical: Number(critical),
        },
      });
    } else {
      row = await prisma.threshold.create({
        data: {
          metricType,
          warning: Number(warning),
          critical: Number(critical),
          serverId: serverId || null,
        },
      });
    }

    return res.json(row);
  } catch (err) {
    return next(err);
  }
}

module.exports = { listThresholds, upsertThreshold };
