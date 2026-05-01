const { failure } = require("../utils/response");
const logger = require("../utils/logger");
const Sentry = require("@sentry/node");
const { ERROR_CODES } = require("../constants");

const errorHandler = (err, req, res, next) => {
  let statusCode = err.status || 500;
  let message = err.message || "Internal server error";
  let code = err.code || ERROR_CODES.INTERNAL_SERVER_ERROR;
  let details = err.details || null;

  // Log error using Winston
  logger.error(`${err.name || 'Error'}: ${message}`, {
    method: req.method,
    path: req.originalUrl,
    requestId: req.id,
    stack: err.stack,
  });

  // Track non-operational errors (bugs) in Sentry
  if (!err.isOperational && process.env.SENTRY_DSN) {
    Sentry.captureException(err);
  }

  // Mongoose CastError (Bad ID)
  if (err.name === "CastError") {
    statusCode = 404;
    message = `Resource not found with id: ${err.value}`;
    code = ERROR_CODES.NOT_FOUND;
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `${field} already exists`;
    code = ERROR_CODES.DUPLICATE_ENTRY;
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    statusCode = 400;
    message = Object.values(err.errors)
      .map((val) => val.message)
      .join(", ");
    code = ERROR_CODES.VALIDATION_ERROR;
  }

  // JWT errors
  if (err.name === "JsonWebTokenError") {
    statusCode = 401;
    message = "Invalid token";
    code = "INVALID_TOKEN";
  }

  if (err.name === "TokenExpiredError") {
    statusCode = 401;
    message = "Token expired";
    code = "TOKEN_EXPIRED";
  }

  return failure(res, {
    status: statusCode,
    message,
    code,
    data: process.env.NODE_ENV === "development" ? { stack: err.stack, details } : details,
  });
};

module.exports = errorHandler;
