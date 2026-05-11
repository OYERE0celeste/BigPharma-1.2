require("dotenv").config();

const app = require("./app");
// Force reload for new transitions

const { initCronJobs } = require("./utils/cronJobs");
const { seedAdmin } = require("./utils/seeder");

const http = require("http");
const { Server } = require("socket.io");
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*", // Adjust in production
    methods: ["GET", "POST"],
  },
});

global.io = io; // Make io accessible globally for emitters

io.on("connection", (socket) => {
  console.log(`New client connected: ${socket.id}`);
  
  socket.on("join-company", (companyId) => {
    socket.join(companyId);
    console.log(`Socket ${socket.id} joined company: ${companyId}`);
  });

  socket.on("disconnect", () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// Global error handlers
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

initCronJobs();
seedAdmin().then(() => {
  const PORT = Number(process.env.PORT || 5000);
  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT} with Real-time Sync (Socket.io) enabled`);
  }).on('error', (err) => {
    console.error('Server listen error:', err);
    process.exit(1);
  });
}).catch((err) => {
  console.error('Seed admin error:', err);
  process.exit(1);
});
