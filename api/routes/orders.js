const express = require("express");
const router = express.Router();
const orderController = require("../controllers/orderController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, isPharmacyStaff } = require("../middleware/roleMiddleware");

router.use(authMiddleware);

router.post("/", isClient, orderController.createOrder);
router.get("/my", isClient, orderController.getMyOrders);
router.get("/:id", orderController.getOrderById);

router.use(isPharmacyStaff);

router.get("/", orderController.getAllOrders);
router.get("/export/orders", orderController.exportOrders);
router.patch("/:id/status", orderController.updateOrderStatus);
router.put("/:id/status", orderController.updateOrderStatus);

module.exports = router;
