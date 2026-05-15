const express = require("express");
const router = express.Router();

const invoiceController = require("../controllers/invoiceController");
const { isClient, isPharmacyStaff, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.get("/my", isClient, invoiceController.getMyInvoices);
router.get("/:id", invoiceController.getInvoiceById);
router.get("/:id/pdf", invoiceController.getInvoicePdf);

router.use(isPharmacyStaff);
router.get("/", requirePermission(PERMISSIONS.VIEW_ORDERS), invoiceController.getMyInvoices);

module.exports = router;
