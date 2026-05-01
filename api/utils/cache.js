const Redis = require("ioredis");
const logger = require("./logger");

let redis;
let redisAvailable = false;
let lastErrorLogged = 0;
const ERROR_LOG_INTERVAL = 60000; // Log error at most once per minute

const useRedis = process.env.REDIS_HOST || process.env.NODE_ENV === "production";

if (useRedis) {
  redis = new Redis({
    host: process.env.REDIS_HOST || "localhost",
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD || undefined,
    retryStrategy: (times) => {
      // Exponential backoff with a cap of 30 seconds
      return Math.min(times * 500, 30000);
    },
    maxRetriesPerRequest: 1, // Fail fast on requests if connection is down
  });

  redis.on("connect", () => {
    logger.info("Connected to Redis");
    redisAvailable = true;
    lastErrorLogged = 0; // Reset error logging when reconnected
  });

  redis.on("error", (err) => {
    redisAvailable = false;
    const now = Date.now();
    if (now - lastErrorLogged > ERROR_LOG_INTERVAL) {
      logger.warn(`Redis Error: ${err.message} (suppressing logs for 60s)`);
      lastErrorLogged = now;
    }
  });
} else {
  logger.info("Redis caching disabled (no REDIS_HOST provided)");
}

exports.get = async (key) => {
  if (!redisAvailable) return null;
  try {
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  } catch (err) {
    // Only log if it's not a connection error (already handled by .on('error'))
    if (err.message && !err.message.includes("ECONNREFUSED")) {
      logger.error(`Cache GET error for key ${key}`, err);
    }
    return null;
  }
};

exports.set = async (key, value, expirySeconds = 3600) => {
  if (!redisAvailable) return;
  try {
    await redis.set(key, JSON.stringify(value), "EX", expirySeconds);
  } catch (err) {
    if (err.message && !err.message.includes("ECONNREFUSED")) {
      logger.error(`Cache SET error for key ${key}`, err);
    }
  }
};

exports.del = async (key) => {
  if (!redisAvailable) return;
  try {
    await redis.del(key);
  } catch (err) {
    if (err.message && !err.message.includes("ECONNREFUSED")) {
      logger.error(`Cache DEL error for key ${key}`, err);
    }
  }
};

exports.delPrefix = async (prefix) => {
  if (!redisAvailable) return;
  try {
    const keys = await redis.keys(`${prefix}*`);
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  } catch (err) {
    if (err.message && !err.message.includes("ECONNREFUSED")) {
      logger.error(`Cache DEL prefix error for ${prefix}`, err);
    }
  }
};
