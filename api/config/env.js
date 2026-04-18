const requiredInNonTest = ["JWT_SECRET", "MONGODB_URI"];

function ensureEnv() {
  const nodeEnv = process.env.NODE_ENV || "development";
  const missing = requiredInNonTest.filter((key) => !process.env[key]);

  if (nodeEnv !== "test" && missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(", ")}`);
  }
}

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET is required");
  }
  return secret;
}

module.exports = {
  ensureEnv,
  getJwtSecret,
};
