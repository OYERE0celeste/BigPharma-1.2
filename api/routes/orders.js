const express = require("express");
const router = express.Router();
const orderController = require("../controllers/orderController");
const prescriptionController = require("../controllers/prescriptionController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, isPharmacyStaff, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");
const { optionalUploadSingle, uploadSingle } = require("../utils/fileUpload");

router.use(authMiddleware);

// ─── Client routes ───────────────────────────────────────────────────────────
router.post("/", isClient, optionalUploadSingle("prescription"), orderController.createOrder);
router.post("/:id/prescription", isClient, uploadSingle("prescription"), orderController.uploadPrescription);
router.get("/:id/prescription", orderController.downloadPrescription);
router.get("/my", isClient, orderController.getMyOrders);
router.get("/my/prescriptions", isClient, prescriptionController.getMyPrescriptions);
router.get("/export", isPharmacyStaff, requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.exportOrders);
router.get("/:id", orderController.getOrderById);
router.get("/:id/invoice", orderController.getOrderInvoice);

// ─── Pharmacy staff routes ───────────────────────────────────────────────────
router.use(isPharmacyStaff);

router.get("/", requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.getAllOrders);
router.get("/prescriptions", requirePermission(PERMISSIONS.VIEW_ORDERS), prescriptionController.listPrescriptions);
router.patch("/:id/status", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.updateOrderStatus);
router.put("/:id/status", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.updateOrderStatus);
router.patch("/:id/prescription/validate", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), prescriptionController.validatePrescription);
router.patch("/:id/prescription/reject", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), prescriptionController.rejectPrescription);

// ─── Substitution routes ────────────────────────────────────────────────────
router.post("/:id/substitute", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.substituteOrderItem);
router.get("/products/:productId/substitutes", requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.getProductSubstitutes);

module.exports = router;
