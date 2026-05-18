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

router.get("/export", requirePermission(PERMISSIONS.MANAGE_SETTINGS), settingsController.exportData);
router.post("/import", requirePermission(PERMISSIONS.MANAGE_SETTINGS), settingsController.importData);

module.exports = router;
