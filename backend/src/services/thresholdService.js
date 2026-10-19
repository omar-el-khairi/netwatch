const prisma = require('../config/db');
const { notifyAlert } = require('./pushService');

const DEFAULTS = {
  cpu: { warning: 70, critical: 90 },
  ram: { warning: 75, critical: 90 },
  disk: { warning: 80, critical: 95 },
};

async function getThresholdsForServer(serverId) {
  const rows = await prisma.threshold.findMany({
    where: {
      OR: [{ serverId }, { serverId: null }],
    },
  });

  const map = { ...DEFAULTS };
  for (const row of rows) {
    if (row.serverId === null && map[row.metricType]) {
      map[row.metricType] = { warning: row.warning, critical: row.critical };
    }
  }
  for (const row of rows) {
    if (row.serverId === serverId) {
      map[row.metricType] = { warning: row.warning, critical: row.critical };
    }
  }
  return map;
}

function levelFor(value, thresholds) {
  if (value >= thresholds.critical) return 'critical';
  if (value >= thresholds.warning) return 'warning';
  return 'ok';
}

/**
 * Compare metrics to thresholds, create alerts, return derived server status.
 */
async function evaluateMetrics(server, metric, io) {
  const thresholds = await getThresholdsForServer(server.id);
  const checks = [
    {
      type: 'CPU_HIGH',
      metricType: 'cpu',
      value: metric.cpuPercent,
      label: 'CPU',
    },
    {
      type: 'RAM_HIGH',
      metricType: 'ram',
      value: metric.ramPercent,
      label: 'RAM',
    },
    {
      type: 'DISK_HIGH',
      metricType: 'disk',
      value: metric.diskPercent,
      label: 'Disque',
    },
  ];

  let worst = 'online';
  const createdAlerts = [];

  for (const check of checks) {
    const t = thresholds[check.metricType];
    const level = levelFor(check.value, t);
    if (level === 'ok') continue;

    if (level === 'critical') worst = 'critical';
    else if (worst !== 'critical') worst = 'warning';

    const since = new Date(Date.now() - 5 * 60 * 1000);
    const existing = await prisma.alert.findFirst({
      where: {
        serverId: server.id,
        type: check.type,
        severity: level,
        createdAt: { gte: since },
      },
    });

    if (!existing) {
      const alert = await prisma.alert.create({
        data: {
          serverId: server.id,
          type: check.type,
          severity: level,
          message: `${check.label} à ${check.value.toFixed(1)}% sur ${server.name} (seuil ${level}: ${level === 'critical' ? t.critical : t.warning}%)`,
          value: check.value,
        },
        include: { server: { select: { id: true, name: true, hostname: true } } },
      });
      createdAlerts.push(alert);
      if (io) io.emit('alert:new', alert);
      notifyAlert(alert).catch(() => {});
    }
  }

  // Services down
  let services = [];
  try {
    services = JSON.parse(metric.servicesJson || '[]');
  } catch {
    services = [];
  }

  for (const svc of services) {
    if (svc && svc.required && !svc.running) {
      if (worst !== 'critical') worst = 'critical';
      const since = new Date(Date.now() - 5 * 60 * 1000);
      const existing = await prisma.alert.findFirst({
        where: {
          serverId: server.id,
          type: 'SERVICE_DOWN',
          message: { contains: svc.name },
          createdAt: { gte: since },
        },
      });
      if (!existing) {
        const alert = await prisma.alert.create({
          data: {
            serverId: server.id,
            type: 'SERVICE_DOWN',
            severity: 'critical',
            message: `Service requis arrêté: ${svc.name} sur ${server.name}`,
          },
          include: { server: { select: { id: true, name: true, hostname: true } } },
        });
        createdAlerts.push(alert);
        if (io) io.emit('alert:new', alert);
        notifyAlert(alert).catch(() => {});
      }
    }
  }

  return { status: worst, alerts: createdAlerts, thresholds };
}

module.exports = {
  DEFAULTS,
  getThresholdsForServer,
  evaluateMetrics,
};
