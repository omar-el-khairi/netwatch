const prisma = require('../config/db');

/**
 * Push notifications (FCM) — optionnel.
 * Sans FIREBASE_SERVICE_ACCOUNT_JSON, les tokens sont stockés
 * et les alertes passent déjà par Socket.IO (mobile + dashboard).
 */
async function registerDevice({ token, platform, userId }) {
  if (!token) throw Object.assign(new Error('token requis'), { status: 400 });
  return prisma.device.upsert({
    where: { token },
    update: {
      platform: platform || 'android',
      userId: userId || null,
    },
    create: {
      token,
      platform: platform || 'android',
      userId: userId || null,
    },
  });
}

async function listDevices() {
  return prisma.device.findMany({ orderBy: { updatedAt: 'desc' } });
}

async function notifyAlert(alert) {
  const devices = await prisma.device.findMany();
  if (!devices.length) return { sent: 0, skipped: 'no-devices' };

  const title = `[NetWatch] ${alert.severity?.toUpperCase() || 'ALERTE'}`;
  const body = alert.message || `${alert.type}`;

  // Optional Firebase Admin
  const credJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!credJson) {
    console.log(`[push] ${devices.length} device(s) enregistré(s) — configurez FIREBASE_SERVICE_ACCOUNT_JSON pour FCM`);
    return { sent: 0, queued: devices.length, mode: 'socket-only' };
  }

  try {
    let admin;
    try {
      admin = require('firebase-admin');
    } catch {
      console.warn('[push] Installez firebase-admin: npm i firebase-admin');
      return { sent: 0, error: 'firebase-admin-missing' };
    }

    if (!admin.apps.length) {
      const cred = JSON.parse(credJson);
      admin.initializeApp({
        credential: admin.credential.cert(cred),
      });
    }

    const tokens = devices.map((d) => d.token);
    const res = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: {
        alertId: String(alert.id || ''),
        type: String(alert.type || ''),
        severity: String(alert.severity || ''),
      },
    });
    console.log(`[push] FCM sent=${res.successCount} fail=${res.failureCount}`);
    return { sent: res.successCount, failed: res.failureCount, mode: 'fcm' };
  } catch (err) {
    console.error('[push]', err.message);
    return { sent: 0, error: err.message };
  }
}

module.exports = { registerDevice, listDevices, notifyAlert };
