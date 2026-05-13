const express = require("express");
const router = express.Router();
const saleController = require("../controllers/saleController");
const authMiddleware = require("../middleware/authMiddleware");
const { requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);

router.post("/", requirePermission(PERMISSIONS.MAKE_SALE), saleController.createSale);
router.get("/", requirePermission(PERMISSIONS.VIEW_SALES_HISTORY), saleController.getSales);
router.patch("/:id/cancel", requirePermission(PERMISSIONS.CANCEL_SALE), saleController.cancelSale);

module.exports = router;
