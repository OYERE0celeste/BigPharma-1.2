const { ROLE_PERMISSIONS } = require("../config/permissions");
const { failure } = require("../utils/response");

/**
 * Middleware to check if user has a specific permission based on their role
 */
const checkPermission = (permission) => {
  return (req, res, next) => {
    if (!req.user) {
      return failure(res, {
        status: 401,
        message: "Authentification requise",
        code: "UNAUTHORIZED",
      });
    }

    const userRole = req.user.role;
    const allowedPermissions = ROLE_PERMISSIONS[userRole] || [];

    if (!allowedPermissions.includes(permission)) {
      return failure(res, {
        status: 403,
        message: `Accès refusé : Permission '${permission}' manquante pour le rôle '${userRole}'`,
        code: "FORBIDDEN",
      });
    }

    next();
  };
};

module.exports = checkPermission;
