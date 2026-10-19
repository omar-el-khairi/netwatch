const http = require('http');
const { Server } = require('socket.io');
const { createApp } = require('./app');
const config = require('./config/env');
const { startHeartbeatMonitor } = require('./services/heartbeatService');

const app = createApp();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: true,
    methods: ['GET', 'POST'],
  },
});

app.set('io', io);

io.on('connection', (socket) => {
  console.log(`[socket] connected ${socket.id}`);
  socket.on('disconnect', () => {
    console.log(`[socket] disconnected ${socket.id}`);
  });
});

const stopHeartbeat = startHeartbeatMonitor(io);

server.listen(config.port, config.host, () => {
  console.log(
    `Supervision backend listening on http://${config.host}:${config.port}`
  );
});

process.on('SIGINT', () => {
  stopHeartbeat();
  server.close(() => process.exit(0));
});
