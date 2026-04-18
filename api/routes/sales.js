const express = require("express");
const router = express.Router();
const saleController = require("../controllers/saleController");
const authMiddleware = require("../middleware/authMiddleware");
const { isPharmacyStaff } = require("../middleware/roleMiddleware");

router.use(authMiddleware);
router.use(isPharmacyStaff);

router.post("/", saleController.createSale);
router.get("/", saleController.getSales);
router.patch("/:id/cancel", saleController.cancelSale);

module.exports = router;

