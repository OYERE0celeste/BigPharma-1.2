const express = require("express");
const router = express.Router();
const settingsController = require("../controllers/settingsController");
const authMiddleware = require("../middleware/authMiddleware");
const { requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);

router.get("/profile", settingsController.getProfileSettings);
router.get("/", requirePermission(PERMISSIONS.MANAGE_SETTINGS), settingsController.getSettings);
router.patch("/system", requirePermission(PERMISSIONS.MANAGE_SETTINGS), settingsController.updateSystemSettings);
router.patch("/pharmacy", requirePermission(PERMISSIONS.MANAGE_SETTINGS), settingsController.updatePharmacyInfo);

module.exports = router;
