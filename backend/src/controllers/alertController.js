const prisma = require('../config/db');

async function listAlerts(req, res, next) {
  try {
    const where = {};
    if (req.query.serverId) where.serverId = req.query.serverId;
    if (req.query.severity) where.severity = req.query.severity;
    if (req.query.acknowledged === 'true') where.acknowledged = true;
    if (req.query.acknowledged === 'false') where.acknowledged = false;

    const alerts = await prisma.alert.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: Math.min(Number(req.query.limit) || 100, 500),
      include: {
        server: { select: { id: true, name: true, hostname: true, osType: true } },
      },
    });

    return res.json(alerts);
  } catch (err) {
    return next(err);
  }
}

async function exportAlerts(req, res, next) {
  try {
    const format = (req.query.format || 'csv').toLowerCase();
    const alerts = await prisma.alert.findMany({
      orderBy: { createdAt: 'desc' },
      take: 1000,
      include: {
        server: { select: { name: true, hostname: true, ipAddress: true } },
      },
    });

    if (format === 'json') {
      return res.json(alerts);
    }

    const header = [
      'id',
      'createdAt',
      'type',
      'severity',
      'server',
      'hostname',
      'ip',
      'message',
      'value',
      'acknowledged',
    ];
    const escape = (v) => {
      const s = v == null ? '' : String(v);
      if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
      return s;
    };
    const lines = [header.join(',')];
    for (const a of alerts) {
      lines.push(
        [
          a.id,
          a.createdAt.toISOString(),
          a.type,
          a.severity,
          a.server?.name,
          a.server?.hostname,
          a.server?.ipAddress,
          a.message,
          a.value,
          a.acknowledged,
        ]
          .map(escape)
          .join(',')
      );
    }

    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="netwatch-alerts-${Date.now()}.csv"`
    );
    return res.send('\uFEFF' + lines.join('\n'));
  } catch (err) {
    return next(err);
  }
}

async function acknowledgeAlert(req, res, next) {
  try {
    const alert = await prisma.alert.update({
      where: { id: req.params.id },
      data: { acknowledged: true },
      include: {
        server: { select: { id: true, name: true, hostname: true } },
      },
    });
    const io = req.app.get('io');
    if (io) io.emit('alert:updated', alert);
    return res.json(alert);
  } catch (err) {
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Alerte introuvable' });
    }
    return next(err);
  }
}

module.exports = { listAlerts, acknowledgeAlert, exportAlerts };
