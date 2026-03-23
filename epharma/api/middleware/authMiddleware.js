const jwt = require("jsonwebtoken");
const User = require("../models/User");

const authMiddleware = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
    try {
      token = req.headers.authorization.split(" ")[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET || "votre_secret_tres_securise_bigpharma_2024");
      req.user = await User.findById(decoded.id).select("-passwordHash");
      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ success: false, message: "Non autorisé, token invalide" });
      return;
    }
  }

  if (!token) {
    res.status(401).json({ success: false, message: "Non autorisé, aucun token" });
    return;
  }
};

module.exports = authMiddleware;
