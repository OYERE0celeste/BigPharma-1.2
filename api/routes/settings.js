const express = require("express");
const router = express.Router();
const settingsController = require("../controllers/settingsController");
const authMiddleware = require("../middleware/authMiddleware");
const { isAdmin } = require("../middleware/roleMiddleware");

router.use(authMiddleware);
router.use(isAdmin);

router.get("/", settingsController.getSettings);
router.patch("/system", settingsController.updateSystemSettings);
router.patch("/pharmacy", settingsController.updatePharmacyInfo);

module.exports = router;
