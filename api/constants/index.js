/**
 * Role Constants
 */
exports.ROLES = {
  ADMIN: "admin",
  PHARMACIST: "pharmacien",
  ASSISTANT: "assistant",
  CASHIER: "caissier",
  CLIENT: "client",
};

/**
 * Order Status Constants
 */
exports.ORDER_STATUS = {
  PENDING: "en_attente",
  PREPARING: "en_preparation",
  READY: "pret_pour_recuperation",
  VALIDATED: "validee",
  CANCELLED: "annulee",
};

/**
 * Error Codes
 */
exports.ERROR_CODES = {
  VALIDATION_ERROR: "VALIDATION_ERROR",
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  NOT_FOUND: "NOT_FOUND",
  CONFLICT: "CONFLICT",
  INTERNAL_SERVER_ERROR: "INTERNAL_SERVER_ERROR",
  DUPLICATE_ENTRY: "DUPLICATE_ENTRY",
  TENANT_VIOLATION: "TENANT_VIOLATION",
};

/**
 * Pagination Defaults
 */
exports.PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
};
