/**
 * Standard success response format
 */
function success(res, { status = 200, data = null, extra = null } = {}) {
  const response = {
    success: true,
    data,
  };
  if (extra) {
    response.extra = extra;
  }
  return res.status(status).json(response);
}

/**
 * Standard failure response format with error code
 */
function failure(res, { status = 400, message = "Erreur", code = "ERROR", data = null } = {}) {
  const response = {
    success: false,
    message,
    code,
  };
  if (data) {
    response.data = data;
  }
  return res.status(status).json(response);
}

module.exports = {
  success,
  failure,
};

