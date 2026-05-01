const { ERROR_CODES } = require("../constants");

/**
 * Standard success response format
 */
function success(res, { status = 200, data = null, meta = null, extra = null } = {}) {
  const response = {
    success: true,
    data,
  };
  
  if (meta) {
    response.meta = meta;
  }
  
  if (extra) {
    response.extra = extra;
  }
  
  return res.status(status).json(response);
}

/**
 * Standard failure response format with error code
 */
function failure(res, { status = 400, message = "Error", code = ERROR_CODES.INTERNAL_SERVER_ERROR, data = null } = {}) {
  const response = {
    success: false,
    error: {
      message,
      code,
      details: data
    }
  };
  
  return res.status(status).json(response);
}

module.exports = {
  success,
  failure,
};
