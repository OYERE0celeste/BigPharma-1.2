const { failure } = require("../utils/response");
const {
  hasAnyPermission,
  hasPermission,
} = require("../utils/rolePermissions");

/**
 * Middleware to check if user has admin role
 */
const isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== "administrateur") {
    return failure(res, {
      status: 403,
      message: "Accès refusé : Administrateur uniquement",
    });
  }
  next();
};

/**
 * Middleware to check if user has client role
 */
const isClient = (req, res, next) => {
  if (!req.user || req.user.role !== "client") {
    return failure(res, {
      status: 403,
      message: "Accès refusé : Client uniquement",
    });
  }
  next();
};

/**
 * Middleware to check if user has any of the pharmacy roles (admin, pharmacien, etc.)
 */
const isPharmacyStaff = (req, res, next) => {
  const pharmacyRoles = ["administrateur", "pharmacien", "gestionnaire de stock", "caissier", "assistante de gestion"];
  if (!req.user || !pharmacyRoles.includes(req.user.role)) {
    return failure(res, {
      status: 403,
      message: "Accès refusé : Personnel de pharmacie uniquement",
    });
  }
  next();
};

const requirePermission = (permission) => (req, res, next) => {
  if (!hasPermission(req.user, permission)) {
    return failure(res, {
      status: 403,
      message: "Acces refuse : permission insuffisante",
      code: "FORBIDDEN",
    });
  }

  return next();
};

const requireAnyPermission = (permissions) => (req, res, next) => {
  if (!hasAnyPermission(req.user, permissions)) {
    return failure(res, {
      status: 403,
      message: "Acces refuse : permission insuffisante",
      code: "FORBIDDEN",
    });
  }

  return next();
};

module.exports = {
  isAdmin,
  isClient,
  isPharmacyStaff,
  requirePermission,
  requireAnyPermission,
};
