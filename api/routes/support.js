const express = require("express");
const router = express.Router();
const supportController = require("../controllers/supportController");
const { isClient, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.get("/", requirePermission(PERMISSIONS.VIEW_SUPPORT), supportController.getQuestions);

router.get("/:id", requirePermission(PERMISSIONS.VIEW_SUPPORT), supportController.getQuestionById);

// Create question (Client only)
router.post("/", isClient, supportController.createQuestion);

router.post("/:id/messages", requirePermission(PERMISSIONS.RESPOND_SUPPORT), supportController.addMessage);

router.patch("/:id/close", requirePermission(PERMISSIONS.RESPOND_SUPPORT), supportController.closeQuestion);

module.exports = router;
