require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const { transformSupplierResponse, transformClientResponse } = require("./middleware/dataTransform");
const authMiddleware = require("./middleware/authMiddleware");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

// Gérer les erreurs de JSON invalide (body-parser)
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      message: 'Corps JSON invalide',
      details: err.message,
    });
  }
  next(err);
});

// Middleware de logging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Routes publiques
app.use("/api/auth", require("./routes/auth"));

// Routes protégées
app.use("/api/users", authMiddleware, require("./routes/users"));
app.use("/api/clients", authMiddleware, require("./routes/clients"));
app.use("/api/suppliers", authMiddleware, require("./routes/suppliers"));
app.use("/api/products", authMiddleware, require("./routes/products"));
app.use("/api/sales", authMiddleware, require("./routes/sales"));
app.use("/api/finance", authMiddleware, require("./routes/finance"));
app.use("/api/dashboard", authMiddleware, require("./routes/dashboard"));
app.use("/api/activityLogs", authMiddleware, require("./routes/activityLogs"));
app.use("/api/consultations", authMiddleware, require("./routes/consultations"));

app.get('/api/test-route', (req, res) => res.json({ success: true, message: 'API test route works' }));

// Gestionnaire 404 JSON pour toutes les routes API manquantes
app.use('/api/', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route API introuvable : ${req.originalUrl}`,
    code: "ROUTE_NOT_FOUND"
  });
});

const errorHandler = require("./middleware/errorMiddleware");

app.use(errorHandler);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Serveur lancé sur le port ${PORT}`);
});