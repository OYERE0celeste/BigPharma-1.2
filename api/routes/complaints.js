const express = require("express");
const router = express.Router();

const complaintController = require("../controllers/complaintController");
const { isClient, isPharmacyStaff, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.get("/my", isClient, complaintController.getMyComplaints);
router.get("/:id", complaintController.getComplaintById);
router.post("/", isClient, complaintController.createComplaint);

router.use(isPharmacyStaff);
router.get("/", requirePermission(PERMISSIONS.VIEW_SUPPORT), complaintController.getMyComplaints);
router.patch("/:id/status", requirePermission(PERMISSIONS.RESPOND_SUPPORT), complaintController.updateComplaintStatus);

module.exports = router;
