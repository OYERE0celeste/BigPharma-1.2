const express = require("express");
const router = express.Router();
const prescriptionController = require("../controllers/prescriptionController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, isPharmacyStaff } = require("../middleware/roleMiddleware");

router.use(authMiddleware);

// Client routes
router.post("/", isClient, prescriptionController.createPrescription);
router.get("/my", isClient, prescriptionController.getMyPrescriptions);

// Pharmacy routes
router.get("/", isPharmacyStaff, prescriptionController.getAllPrescriptions);
router.put("/:id/validate", isPharmacyStaff, prescriptionController.validatePrescription);
router.patch("/:id/validate", isPharmacyStaff, prescriptionController.validatePrescription);

module.exports = router;
