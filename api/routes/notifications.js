const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notificationController");
const authMiddleware = require("../middleware/authMiddleware");
const { requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);
router.use(requirePermission(PERMISSIONS.VIEW_NOTIFICATIONS));

router.get("/test", notificationController.sendTestNotification);
router.get("/", notificationController.getMyNotifications);

router.put("/mark-all-read", notificationController.markAllAsRead);
router.put("/:id/read", notificationController.markAsRead);
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
