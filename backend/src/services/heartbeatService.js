const prisma = require('../config/db');
const config = require('../config/env');
const { notifyAlert } = require('./pushService');

function startHeartbeatMonitor(io) {
  const intervalMs = config.heartbeatCheckIntervalSeconds * 1000;
  const timeoutMs = config.heartbeatTimeoutSeconds * 1000;

  const timer = setInterval(async () => {
    try {
      const cutoff = new Date(Date.now() - timeoutMs);
      const stale = await prisma.server.findMany({
        where: {
          status: { not: 'down' },
          OR: [
            { lastSeenAt: { lt: cutoff } },
            { AND: [{ lastSeenAt: null }, { status: { not: 'pending' } }] },
          ],
        },
      });

      // Also mark servers that were online but never sent after being pending too long? skip pending without lastSeen
      const candidates = await prisma.server.findMany({
        where: {
          lastSeenAt: { not: null, lt: cutoff },
          status: { not: 'down' },
        },
      });

      for (const server of candidates) {
        const updated = await prisma.server.update({
          where: { id: server.id },
          data: { status: 'down' },
        });

        const since = new Date(Date.now() - 2 * timeoutMs);
        const existing = await prisma.alert.findFirst({
          where: {
            serverId: server.id,
            type: 'SERVER_DOWN',
            createdAt: { gte: since },
          },
        });

        if (!existing) {
          const alert = await prisma.alert.create({
            data: {
              serverId: server.id,
              type: 'SERVER_DOWN',
              severity: 'critical',
              message: `Serveur injoignable: ${server.name} (${server.hostname}) — aucune métrique depuis ${config.heartbeatTimeoutSeconds}s`,
            },
            include: {
              server: { select: { id: true, name: true, hostname: true } },
            },
          });
          if (io) io.emit('alert:new', alert);
          notifyAlert(alert).catch(() => {});
        }

        if (io) io.emit('server:update', updated);
      }

      // silence unused
      void stale;
    } catch (err) {
      console.error('[heartbeat]', err.message);
    }
  }, intervalMs);

  return () => clearInterval(timer);
}

module.exports = { startHeartbeatMonitor };
