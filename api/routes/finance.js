const express = require("express");
const router = express.Router();
const financeController = require("../controllers/financeController");
const authMiddleware = require("../middleware/authMiddleware");
const { requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

router.use(authMiddleware);

router.get("/", requirePermission(PERMISSIONS.VIEW_FINANCIAL_REPORTS), financeController.getFinanceSummary);
router.get("/summary", requirePermission(PERMISSIONS.VIEW_FINANCIAL_REPORTS), financeController.getFinanceSummary);
router.post("/manual", requirePermission(PERMISSIONS.ADD_FINANCE_ENTRY), financeController.addManualEntry);

module.exports = router;
