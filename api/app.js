require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const morgan = require("morgan");
const Sentry = require("@sentry/node");
const mongoSanitize = require("express-mongo-sanitize");
const xss = require("xss-clean");
const cookieParser = require("cookie-parser");
const compression = require("compression");
const swaggerUi = require("swagger-ui-express");
const hpp = require("hpp");
const swaggerSpecs = require("./config/swagger");

const connectDB = require("./config/db");
const { ensureEnv } = require("./config/env");
const authMiddleware = require("./middleware/authMiddleware");
const errorMiddleware = require("./middleware/errorMiddleware");
const requestIdMiddleware = require("./middleware/requestIdMiddleware");
const { metricsMiddleware, register } = require("./middleware/metricsMiddleware");
const { success, failure } = require("./utils/response");
const logger = require("./utils/logger");

const app = express();

// 1. Initialize Sentry
if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV || "development",
    integrations: [
      new Sentry.Integrations.Http({ tracing: true }),
      new Sentry.Integrations.Express({ app }),
    ],
    tracesSampleRate: 1.0,
  });
}

// 2. Security and Logging Middlewares
if (process.env.SENTRY_DSN) {
  app.use(Sentry.Handlers.requestHandler());
  app.use(Sentry.Handlers.tracingHandler());
}

// Global Rate Limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: "Too many requests from this IP, please try again after 15 minutes",
});
app.use(globalLimiter);

// Compression
app.use(compression());

// Security headers with CSP
// app.use(
//   helmet({
//     contentSecurityPolicy: {
//       directives: {
//         defaultSrc: ["'self'"],
//         scriptSrc: ["'self'", "'unsafe-inline'"],
//         styleSrc: ["'self'", "'unsafe-inline'"],
//         imgSrc: ["'self'", "data:", "https:"],
//         connectSrc: ["'self'", "https://sentry.io", "http://localhost:5000", "http://127.0.0.1:5000", "ws://localhost:5000", "ws://127.0.0.1:5000"],
//       },
//     },
//     crossOriginEmbedderPolicy: false,
//     referrerPolicy: { policy: "strict-origin-when-cross-origin" },
//   })
// );

// app.use(mongoSanitize());
// app.use(xss());
app.use(cookieParser());
app.use(requestIdMiddleware);
app.use(metricsMiddleware);

// Morgan integration with Winston
app.use(
  morgan(":method :url :status :res[content-length] - :response-time ms", {
    stream: { write: (message) => logger.info(message.trim()) },
  })
);

ensureEnv();
connectDB().catch((error) => {
  logger.error("Unable to connect database", error);
  process.exit(1);
});

const nodeEnv = process.env.NODE_ENV || "development";
const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((o) => o.trim()).filter(Boolean)
  : ["*"];

function isLocalDevelopmentOrigin(origin) {
  if (nodeEnv === "production") return false;
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
      if (!origin || allowedOrigins.includes("*") || allowedOrigins.includes(origin) || isLocalDevelopmentOrigin(origin)) {
        return callback(null, true);
      }
      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
  })
);

app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use(hpp()); // Prevent HTTP Parameter Pollution

// Health check
app.get("/health", (req, res) => {
  return success(res, {
    data: { status: "healthy", timestamp: new Date().toISOString(), environment: nodeEnv, requestId: req.id },
  });
});

// Metrics
app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

// Documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

// API Routes with Versioning
const apiV1 = express.Router();
const tenantEnforcer = require("./middleware/tenantEnforcer");

apiV1.use("/auth", authLimiter, require("./routes/auth"));
apiV1.use("/products", require("./routes/products"));

// Protected routes with Tenant Enforcement
apiV1.use(authMiddleware);
apiV1.use(tenantEnforcer);

apiV1.use("/users", require("./routes/users"));
apiV1.use("/clients", require("./routes/clients"));
apiV1.use("/orders", require("./routes/orders"));
apiV1.use("/prescriptions", require("./routes/prescriptions"));
apiV1.use("/sales", require("./routes/sales"));
apiV1.use("/finance", require("./routes/finance"));
apiV1.use("/activities", require("./routes/activityLogs"));
apiV1.use("/activityLogs", require("./routes/activityLogs"));
apiV1.use("/consultations", require("./routes/consultations"));
apiV1.use("/QuestionsClients", require("./routes/QuestionsClients"));
apiV1.use("/dashboard", require("./routes/dashboard"));
apiV1.use("/mouvements", require("./routes/mouvements"));
apiV1.use("/settings", require("./routes/settings"));

app.use("/api/v1", apiV1);
app.use("/api", apiV1); // Compatibility layer

// 404 handler
app.use((req, res) => {
  return failure(res, { status: 404, message: "Endpoint not found", code: "NOT_FOUND" });
});

if (process.env.SENTRY_DSN) {
  app.use(Sentry.Handlers.errorHandler());
}

app.use(errorMiddleware);

module.exports = app;
