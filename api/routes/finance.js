const express = require("express");
const router = express.Router();
const financeController = require("../controllers/financeController");
const authMiddleware = require("../middleware/authMiddleware");
const { isAdmin } = require("../middleware/roleMiddleware");

router.use(authMiddleware);
router.use(isAdmin); // Restricted to admin

router.get("/summary", financeController.getFinanceSummary);
router.post("/manual", financeController.addManualEntry);

module.exports = router;
