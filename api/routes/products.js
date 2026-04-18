const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");
const authMiddleware = require("../middleware/authMiddleware");
const optionalAuthMiddleware = require("../middleware/optionalAuthMiddleware");
const { isAdmin, isPharmacyStaff } = require("../middleware/roleMiddleware");

// Public routes (accessible to all with optional auth)
router.get("/", optionalAuthMiddleware, productController.getProducts);
router.get("/:id", optionalAuthMiddleware, productController.getProductById);

// Protected routes (requires authentication)
router.use(authMiddleware);

// Pharmacy staff routes
router.patch("/:id/stock", isPharmacyStaff, productController.updateStock);
router.get("/export/inventory", isPharmacyStaff, productController.exportInventory);

// Admin only routes
router.post("/", isAdmin, productController.createProduct);
router.put("/:id", isAdmin, productController.updateProduct);
router.delete("/:id", isAdmin, productController.deleteProduct);

module.exports = router;

