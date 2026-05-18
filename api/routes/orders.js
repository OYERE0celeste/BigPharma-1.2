const express = require("express");
const router = express.Router();
const orderController = require("../controllers/orderController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, isPharmacyStaff, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);

router.post("/", isClient, orderController.createOrder);
router.get("/my", isClient, orderController.getMyOrders);
router.get("/:id", orderController.getOrderById);
router.get("/:id/invoice", orderController.getOrderInvoice);

router.use(isPharmacyStaff);

router.get("/", requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.getAllOrders);
router.get("/export", // changed from /export/orders\n   requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.exportOrders);
router.patch("/:id/status", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.updateOrderStatus);
router.put("/:id/status", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.updateOrderStatus);

// Substitution routes
router.post("/:id/substitute", requirePermission(PERMISSIONS.UPDATE_ORDER_STATUS), orderController.substituteOrderItem);
router.get("/products/:productId/substitutes", requirePermission(PERMISSIONS.VIEW_ORDERS), orderController.getProductSubstitutes);

module.exports = router;
