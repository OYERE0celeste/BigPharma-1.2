const express = require("express");
const router = express.Router();

const reviewController = require("../controllers/reviewController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, isPharmacyStaff, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.get("/product/:productId", reviewController.getProductReviews);

router.use(authMiddleware);

router.get("/my", isClient, reviewController.getMyReviews);
router.post("/", isClient, reviewController.createReview);
router.get("/", isPharmacyStaff, requirePermission(PERMISSIONS.VIEW_SUPPORT), reviewController.getCompanyReviews);
router.patch("/:id/response", isPharmacyStaff, requirePermission(PERMISSIONS.RESPOND_SUPPORT), reviewController.respondToReview);

module.exports = router;
