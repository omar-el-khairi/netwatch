const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function ensureServer({ name, hostname, ipAddress, osType }) {
  const existing = await prisma.server.findFirst({ where: { hostname } });
  if (existing) {
    console.log(`Serveur déjà présent [${hostname}] API KEY: ${existing.apiKey}`);
    return existing;
  }
  const server = await prisma.server.create({
    data: {
      name,
      hostname,
      ipAddress,
      osType,
      apiKey: crypto.randomBytes(24).toString('hex'),
      status: 'pending',
    },
  });
  console.log(`Serveur créé [${hostname}] API KEY: ${server.apiKey}`);
  return server;
}

async function main() {
  const passwordHash = await bcrypt.hash('Admin123!', 10);

  await prisma.user.upsert({
    where: { email: 'admin@supervision.local' },
    update: {},
    create: {
      email: 'admin@supervision.local',
      passwordHash,
      name: 'Administrateur',
      role: 'admin',
    },
  });

  const defaults = [
    { metricType: 'cpu', warning: 70, critical: 90 },
    { metricType: 'ram', warning: 75, critical: 90 },
    { metricType: 'disk', warning: 80, critical: 95 },
  ];

  for (const d of defaults) {
    const existing = await prisma.threshold.findFirst({
      where: { metricType: d.metricType, serverId: null },
    });
    if (!existing) {
      await prisma.threshold.create({ data: d });
    }
  }

  // Multi-machines pour la démo
  await ensureServer({
    name: 'Serveur Démo Local',
    hostname: 'demo-local',
    ipAddress: '127.0.0.1',
    osType: process.platform === 'win32' ? 'windows' : 'linux',
  });

  await ensureServer({
    name: 'CentOS Lab',
    hostname: 'centos-lab',
    ipAddress: '192.168.88.129',
    osType: 'linux',
  });

  console.log('Seed OK — admin@supervision.local / Admin123!');
  console.log('2 serveurs prêts pour la démo multi-machines.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
