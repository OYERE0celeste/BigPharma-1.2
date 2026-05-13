const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { getJwtSecret } = require("../config/env");
const { failure } = require("../utils/response");
const { resolveUserPermissions } = require("../utils/rolePermissions");

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    return failure(res, {
      status: 401,
      message: "Unauthorized: missing bearer token",
      code: "UNAUTHORIZED",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, getJwtSecret());
    const user = await User.findById(decoded.id).select("-passwordHash");

    if (!user || !user.isActive) {
      return failure(res, {
        status: 401,
        message: "Unauthorized: account not available",
        code: "UNAUTHORIZED",
      });
    }

    user.permissions = resolveUserPermissions(user);
    req.user = user;
    return next();
  } catch (error) {
    return failure(res, {
      status: 401,
      message: "Unauthorized: invalid or expired token",
      code: "UNAUTHORIZED",
    });
  }
};

module.exports = authMiddleware;
