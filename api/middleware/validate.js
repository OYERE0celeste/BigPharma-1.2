const validate = (schema, property = "body") => {
  return async (req, res, next) => {
    try {
      const value = await schema.validateAsync(req[property], {
        abortEarly: false,
        stripUnknown: true,
      });
      req[property] = value;
      return next();
    } catch (error) {
      const details = error.details?.map((d) => d.message).filter(Boolean) || [error.message];
      const message = Array.isArray(details) ? details.join(" / ") : error.message;

      return res.status(400).json({
        success: false,
        message,
        data: {
          details,
        },
        code: "VALIDATION_ERROR",
      });
    }
  };
};

module.exports = validate;
