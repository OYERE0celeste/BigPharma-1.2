const rateLimit = require("express-rate-limit");

/**
 * Strict rate limiter for sensitive actions like login, register, password reset.
 */
exports.sensitiveActionLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 requests per hour per IP
  message: {
    success: false,
    error: {
      message: "Too many attempts. Please try again after an hour.",
      code: "STRICT_RATE_LIMIT_EXCEEDED"
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Standard user action limiter (e.g. creating a resource)
 */
exports.userActionLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // 50 requests per 15 minutes per IP
  message: {
    success: false,
    error: {
      message: "Too many actions. Please slow down.",
      code: "RATE_LIMIT_EXCEEDED"
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
});
