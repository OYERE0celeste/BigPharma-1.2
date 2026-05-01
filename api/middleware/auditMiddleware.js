const { logActivity } = require("../utils/activityLogger");

const auditAccess = (action, entityType) => {
  return async (req, res, next) => {
    const originalSend = res.send;
    
    res.send = function (data) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        logActivity({
          actionType: action,
          entityType: entityType,
          entityId: req.params.id || "list",
          description: `Audit: ${req.user.fullName} (${req.user.role}) accessed ${req.originalUrl}`,
          companyId: req.user.companyId,
          user: req.user.fullName,
          status: "success"
        }).catch(err => console.error("Audit log failed", err));
      }
      originalSend.apply(res, arguments);
    };
    
    next();
  };
};

module.exports = auditAccess;
