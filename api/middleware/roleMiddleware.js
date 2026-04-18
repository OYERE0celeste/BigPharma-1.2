const { failure } = require("../utils/response");

/**
 * Middleware to check if user has admin role
 */
const isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== "admin") {
    return failure(res, {
      status: 403,
      message: "Accès refusé : Admin uniquement",
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
  const pharmacyRoles = ["admin", "pharmacien", "assistant", "caissier"];
  if (!req.user || !pharmacyRoles.includes(req.user.role)) {
    return failure(res, {
      status: 403,
      message: "Accès refusé : Personnel de pharmacie uniquement",
    });
  }
  next();
};

module.exports = {
  isAdmin,
  isClient,
  isPharmacyStaff,
};
