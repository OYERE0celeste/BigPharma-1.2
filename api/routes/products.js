const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");
const authMiddleware = require("../middleware/authMiddleware");
const optionalAuthMiddleware = require("../middleware/optionalAuthMiddleware");
const { requirePermission } = require("../middleware/roleMiddleware");
const validate = require("../middleware/validate");
const { createProductSchema, updateProductSchema } = require("../validation/productSchemas");
const { PERMISSIONS } = require("../utils/rolePermissions");

// Public routes (accessible to all with optional auth)
router.get("/", optionalAuthMiddleware, productController.getProducts);
router.get("/:id", optionalAuthMiddleware, productController.getProductById);

// Protected routes (requires authentication)
router.use(authMiddleware);

// Pharmacy staff routes
router.patch("/:id/stock", requirePermission(PERMISSIONS.EDIT_STOCK), productController.updateStock);
router.get("/alerts/status", requirePermission(PERMISSIONS.VIEW_STOCK_ALERTS), productController.getStockAlerts);
router.get("/export/inventory", requirePermission(PERMISSIONS.VIEW_STOCK_REPORTS), productController.exportInventory);

router.post("/", requirePermission(PERMISSIONS.ADD_PRODUCT), validate(createProductSchema), productController.createProduct);
router.put("/:id", requirePermission(PERMISSIONS.EDIT_PRODUCT), validate(updateProductSchema), productController.updateProduct);
router.delete("/:id", requirePermission(PERMISSIONS.DELETE_PRODUCT), productController.deleteProduct);

module.exports = router;
