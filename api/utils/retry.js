const logger = require("./logger");

/**
 * Executes a function with exponential backoff retry logic.
 * @param {Function} fn - Function to execute
 * @param {number} retries - Max retries
 * @param {number} delay - Initial delay in ms
 */
exports.withRetry = async (fn, retries = 3, delay = 1000) => {
  try {
    return await fn();
  } catch (error) {
    if (retries <= 0) {
      throw error;
    }

    logger.warn(`Retrying action... Attempts left: ${retries}. Waiting ${delay}ms`);
    
    await new Promise((resolve) => setTimeout(resolve, delay));
    
    // Exponential backoff
    return exports.withRetry(fn, retries - 1, delay * 2);
  }
};
