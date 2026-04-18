require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");

const connectDB = require("./config/db");
const { ensureEnv } = require("./config/env");
const authMiddleware = require("./middleware/authMiddleware");
const optionalAuthMiddleware = require("./middleware/optionalAuthMiddleware");
const errorMiddleware = require("./middleware/errorMiddleware");
const { success, failure } = require("./utils/response");

const app = express();

ensureEnv();
connectDB().catch((error) => {
  console.error("Unable to connect database", error);
  process.exit(1);
});

const nodeEnv = process.env.NODE_ENV || "development";
const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim()).filter(Boolean)
  : ["*"];

function isLocalDevelopmentOrigin(origin) {
  if (nodeEnv === "production") {
    return false;
  }

  try {
    const parsedOrigin = new URL(origin);
    return ["localhost", "127.0.0.1", "::1"].includes(parsedOrigin.hostname);
  } catch (_) {
    return false;
  }
}

app.use(
  cors({
    origin: (origin, callback) => {
      if (
        !origin ||
        allowedOrigins.includes("*") ||
        allowedOrigins.includes(origin) ||
        isLocalDevelopmentOrigin(origin)
      ) {
        return callback(null, true);
      }
      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
  })
);

app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
  })
);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    return failure(res, {
      status: 400,
      message: "Invalid JSON body",
      code: "BAD_REQUEST",
      data: { details: err.message },
    });
  }
  return next(err);
});

// Health check endpoint
app.get("/api/health", (req, res) => {
  return success(res, {
    data: {
      status: "healthy",
      timestamp: new Date().toISOString(),
      environment: nodeEnv,
    },
  });
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use("/api/auth", authLimiter, require("./routes/auth"));
app.use("/api/products", require("./routes/products"));
app.use("/api/users", authMiddleware, require("./routes/users"));
app.use("/api/clients", require("./routes/clients"));
app.use("/api/orders", require("./routes/orders"));
app.use("/api/prescriptions", require("./routes/prescriptions"));
app.use("/api/sales", authMiddleware, require("./routes/sales"));
app.use("/api/finance", authMiddleware, require("./routes/finance"));
app.use("/api/activityLogs", authMiddleware, require("./routes/activityLogs"));
app.use("/api/consultations", authMiddleware, require("./routes/consultations"));
app.use("/api/QuestionsClients", authMiddleware, require("./routes/QuestionsClients"));
app.use("/api/dashboard", authMiddleware, require("./routes/dashboard"));
app.use("/api/mouvements", authMiddleware, require("./routes/mouvements"));
app.use("/api/settings", authMiddleware, require("./routes/settings"));

// 404 handler
app.use((req, res) => {
  return failure(res, {
    status: 404,
    message: "Endpoint not found",
    code: "NOT_FOUND",
  });
});

// Global error handling middleware (MUST be last)
app.use(errorMiddleware);

module.exports = app;

app.get("/api/test-route", (req, res) => {
  return success(res, {
    message: "Unified API ready",
    data: { status: "ok" },
  });
});

app.use("/api", (req, res) => {
  return failure(res, {
    status: 404,
    message: `API route not found: ${req.originalUrl}`,
    code: "NOT_FOUND",
  });
});

const errorHandler = require("./middleware/errorMiddleware");
app.use(errorHandler);

module.exports = app;
