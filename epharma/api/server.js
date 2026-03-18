const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
//const { transformSupplierResponse, transformClientResponse } = require("./middleware/dataTransform");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

//app.use("/api/suppliers", transformSupplierResponse);
//app.use("/api/clients", transformClientResponse);

app.use("/api/clients", require("./routes/clients"));
//app.use("/api/suppliers", require("./routes/suppliers"));
app.use("/api/products", require("./routes/products"));
//app.use("/api/consultations", require("./routes/consultations"));
app.use("/api/sales", require("./routes/sales"));
app.get('/api/sales/test', (req, res) => res.json({ success: true, message: 'Sales test route works' }));
//app.use("/api/activity-logs", require("./routes/activityLogs"));
//app.use("/api/dashboard", require("./routes/dashboard"));

const PORT = 5000;

app.listen(PORT, () => {
  console.log(`Serveur lancé sur le port ${PORT}`);
});