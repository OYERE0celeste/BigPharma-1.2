const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notificationController");

router.get("/test", notificationController.sendTestNotification);
router.get("/", notificationController.getMyNotifications);

router.put("/mark-all-read", notificationController.markAllAsRead);
router.put("/:id/read", notificationController.markAsRead);
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
