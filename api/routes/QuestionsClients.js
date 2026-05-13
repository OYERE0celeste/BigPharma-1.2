const express = require("express");
const router = express.Router();
const supportController = require("../controllers/supportController");
const { isClient, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

// Get all questions (filtered by role automatically in controller)
router.get("/", requirePermission(PERMISSIONS.VIEW_SUPPORT), supportController.getQuestions);

// Get specific question
router.get("/:id", requirePermission(PERMISSIONS.VIEW_SUPPORT), supportController.getQuestionById);

// Create question (Client only)
router.post("/", isClient, supportController.createQuestion);

// Add message to question
router.post("/:id/messages", requirePermission(PERMISSIONS.RESPOND_SUPPORT), supportController.addMessage);

// Close question (Pharmacy staff only)
router.patch("/:id/close", requirePermission(PERMISSIONS.RESPOND_SUPPORT), supportController.closeQuestion);

module.exports = router;
