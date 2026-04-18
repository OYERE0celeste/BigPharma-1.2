const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { getJwtSecret } = require("../config/env");

const optionalAuthMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    return next();
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, getJwtSecret());
    const user = await User.findById(decoded.id).select("-passwordHash");
    if (user && user.isActive) {
      req.user = user;
    }
  } catch (error) {
    // optional auth: silently ignore token errors
  }

  return next();
};

module.exports = optionalAuthMiddleware;
