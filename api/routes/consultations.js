const express = require("express");
const router = express.Router();
const Consultation = require("../models/consultation");

// GET /api/consultations
router.get("/", async (req, res) => {
  try {
    const consultations = await Consultation.find({ companyId: req.user.companyId })
      .populate("clientId", "firstName lastName")
      .sort({ date: -1 });
    res.json({ success: true, data: consultations });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/consultations
router.post("/", async (req, res) => {
  try {
    const newConsultation = new Consultation({
      ...req.body,
      companyId: req.user.companyId,
    });
    const savedConsultation = await newConsultation.save();
    res.status(201).json({ success: true, data: savedConsultation });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
});

module.exports = router;
