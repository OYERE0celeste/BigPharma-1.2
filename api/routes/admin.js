const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");

// POST /api/v1/admin/scan - trigger a manual stock/expiration scan
router.post("/scan", adminController.triggerScan);

module.exports = router;
