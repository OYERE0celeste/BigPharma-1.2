const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const authMiddleware = require("../middleware/authMiddleware");
const validate = require("../middleware/validate");
const { createStaffSchema } = require("../validation/authSchemas");
const { requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);
router.use(requirePermission(PERMISSIONS.MANAGE_USERS));

router.get("/", userController.getAllStaff);
router.post("/", validate(createStaffSchema), userController.createStaff);
router.get("/staff", userController.getAllStaff);
router.post("/staff", validate(createStaffSchema), userController.createStaff);
router.patch("/staff/:id", userController.updateStaff);
router.delete("/staff/:id", userController.deleteStaff);

module.exports = router;
