require("./config/loadEnv");

const http = require("http");
const net = require("net");
const { initCronJobs } = require("./utils/cronJobs");
const { seedAdmin } = require("./utils/seeder");

const PORT = Number(process.env.PORT || 5000);

// Global error handlers
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

function isPortListening(port) {
  return new Promise((resolve) => {
    const socket = net.createConnection({ host: "127.0.0.1", port });

    socket.setTimeout(1000);

    socket.on("connect", () => {
      socket.destroy();
      resolve(true);
    });

    socket.on("timeout", () => {
      socket.destroy();
      resolve(false);
    });

    socket.on("error", (error) => {
      if (error.code === "ECONNREFUSED") {
        resolve(false);
        return;
      }

      resolve(true);
    });
  });
}

function isBigPharmaInstanceRunning(port) {
  return new Promise((resolve) => {
    const request = http.request(
      {
        host: "127.0.0.1",
        port,
        path: "/api/health",
        method: "GET",
        timeout: 1500,
      },
      (response) => {
        let body = "";

        response.setEncoding("utf8");
        response.on("data", (chunk) => {
          body += chunk;
        });
        response.on("end", () => {
          try {
            const payload = JSON.parse(body);
            resolve(response.statusCode === 200 && payload?.success === true && payload?.data?.status === "healthy");
          } catch (_) {
            resolve(false);
          }
        });
      }
    );

    request.on("timeout", () => {
      request.destroy();
      resolve(false);
    });

    request.on("error", () => {
      resolve(false);
    });

    request.end();
  });
}

async function inspectPort(port) {
  const occupied = await isPortListening(port);

  if (!occupied) {
    return "available";
  }

  if (await isBigPharmaInstanceRunning(port)) {
    return "bigpharma";
  }

  return "occupied";
}

function attachRealtime(server) {
  const { Server } = require("socket.io");
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
      socket.join(companyId.toString());
      console.log(`Socket ${socket.id} joined company: ${companyId}`);
    });

    socket.on("join-user", (userId) => {
      socket.join(userId.toString());
      console.log(`Socket ${socket.id} joined user room: ${userId}`);
    });

    socket.on("disconnect", () => {
      console.log(`Client disconnected: ${socket.id}`);
    });
  });
}

async function handleListenError(err, port) {
  if (err.code === "EADDRINUSE") {
    const status = await inspectPort(port);

    if (status === "bigpharma") {
      console.log(
        `BigPharma API is already running on http://localhost:${port}. This process will exit instead of starting a duplicate instance.`
      );
      process.exit(0);
      return;
    }

    console.error(`Port ${port} is already in use by another process. Stop it or change PORT in api/.env.`);
    process.exit(1);
    return;
  }

  console.error("Server listen error:", err);
  process.exit(1);
}

async function startServer() {
  const portStatus = await inspectPort(PORT);

  if (portStatus === "bigpharma") {
    console.log(
      `BigPharma API is already running on http://localhost:${PORT}. Reuse that instance or stop it before starting a new one.`
    );
    return;
  }

  if (portStatus === "occupied") {
    console.error(`Port ${PORT} is already in use by another process. Stop it or change PORT in api/.env.`);
    process.exit(1);
    return;
  }

  const app = require("./app");
  const server = http.createServer(app);

  attachRealtime(server);
  await seedAdmin();

  server.on("error", (err) => {
    void handleListenError(err, PORT);
  });

  server.listen(PORT, () => {
    initCronJobs();
    console.log(`Server running on port ${PORT} with Real-time Sync (Socket.io) enabled`);
  });
}

startServer().catch((err) => {
  console.error("Startup error:", err);
  process.exit(1);
});
