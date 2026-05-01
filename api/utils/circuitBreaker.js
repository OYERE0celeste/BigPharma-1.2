const CircuitBreaker = require("opossum");
const logger = require("./logger");

const options = {
  timeout: 3000, // If the action takes longer than 3 seconds, fail it
  errorThresholdPercentage: 50, // When 50% of requests fail, open the circuit
  resetTimeout: 30000, // After 30 seconds, try to close the circuit again
};

/**
 * Creates a circuit breaker for a given function
 */
exports.createBreaker = (action, name = "Unnamed Service") => {
  const breaker = new CircuitBreaker(action, options);

  breaker.on("open", () => logger.error(`Circuit Breaker OPEN for ${name}`));
  breaker.on("halfOpen", () => logger.warn(`Circuit Breaker HALF-OPEN for ${name}`));
  breaker.on("close", () => logger.info(`Circuit Breaker CLOSED for ${name}`));
  breaker.on("fallback", (data) => logger.warn(`Circuit Breaker FALLBACK for ${name}`));

  return breaker;
};
