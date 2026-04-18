const { failure } = require("../utils/response");

const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || "Internal server error";
  let code = err.code || "SERVER_ERROR";

  console.error(`[Error] ${req.method} ${req.originalUrl}`, err);

  // Mongoose CastError
  if (err.name === "CastError") {
    statusCode = 404;
    message = `Resource not found for id ${err.value}`;
    code = "NOT_FOUND";
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `${field} already exists`;
    code = "DUPLICATE_ENTRY";
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    statusCode = 400;
    message = Object.values(err.errors).map((val) => val.message).join(", ");
    code = "VALIDATION_ERROR";
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
    data: process.env.NODE_ENV === "development" ? { details: err.stack } : null,
  });
};

module.exports = errorHandler;
