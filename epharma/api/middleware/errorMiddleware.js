const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || "Erreur Interne du Serveur";
  let code = err.code || "SERVER_ERROR";

  // Log to console for dev
  console.error(`[Error] ${req.method} ${req.originalUrl}:`, err);

  // Mongoose bad ObjectId
  if (err.name === "CastError") {
    message = `Ressource non trouvée avec l'id ${err.value}`;
    statusCode = 404;
    code = "NOT_FOUND";
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    message = "Valeur en double détectée";
    statusCode = 400;
    code = "DUPLICATE_KEY";
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    message = Object.values(err.errors).map((val) => val.message).join(", ");
    statusCode = 400;
    code = "VALIDATION_ERROR";
  }

  res.status(statusCode).json({
    success: false,
    message,
    code,
  });
};

module.exports = errorHandler;
