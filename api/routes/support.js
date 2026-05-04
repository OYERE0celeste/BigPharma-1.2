const express = require("express");
const router = express.Router();
const supportController = require("../controllers/supportController");
const { isClient, isPharmacyStaff } = require("../middleware/roleMiddleware");

// Get all questions (filtered by role automatically in controller)
router.get("/", supportController.getQuestions);

// Get specific question
router.get("/:id", supportController.getQuestionById);

// Create question (Client only)
router.post("/", isClient, supportController.createQuestion);

// Add message to question
router.post("/:id/messages", supportController.addMessage);

// Close question (Pharmacy staff only)
router.patch("/:id/close", isPharmacyStaff, supportController.closeQuestion);

module.exports = router;
