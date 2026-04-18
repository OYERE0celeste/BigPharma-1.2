const { failure } = require("../utils/response");

const authorizeRoles = (roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return failure(res, {
        status: 403,
        message: `Role ${req.user ? req.user.role : "unknown"} is not allowed`,
        code: "FORBIDDEN",
      });
    }
    return next();
  };
};

module.exports = authorizeRoles;
