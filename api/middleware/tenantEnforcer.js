const { failure } = require("../utils/response");

/**
 * Middleware to enforce multi-tenancy.
 * Ensures that if a companyId is provided in req.body or req.query, it matches req.user.companyId.
 * For admins, it might allow overriding, but for regular users, it forces req.user.companyId.
 */
const enforceTenant = (req, res, next) => {
  if (!req.user || !req.user.companyId) {
    return next();
  }

  const userCompanyId = req.user.companyId.toString();

  // Force companyId in body for create/update operations
  if (req.method === "POST" || req.method === "PUT" || req.method === "PATCH") {
    if (req.body.companyId && req.body.companyId !== userCompanyId) {
      return failure(res, {
        status: 403,
        message: "Multi-tenancy violation: You cannot perform actions for another company",
        code: "TENANT_VIOLATION"
      });
    }
    req.body.companyId = userCompanyId;
  }

  // Force companyId in query for GET operations
  if (req.method === "GET") {
    if (req.query.companyId && req.query.companyId !== userCompanyId) {
       // Silent fix or error? Let's go with silent fix for better UX
       req.query.companyId = userCompanyId;
    } else {
       req.query.companyId = userCompanyId;
    }
  }

  next();
};

module.exports = enforceTenant;
