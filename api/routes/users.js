const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const authMiddleware = require("../middleware/authMiddleware");
const { isAdmin } = require("../middleware/roleMiddleware");

router.use(authMiddleware);
router.use(isAdmin);

router.get("/staff", userController.getAllStaff);
router.post("/staff", userController.createStaff);
router.patch("/staff/:id", userController.updateStaff);
router.delete("/staff/:id", userController.deleteStaff);

module.exports = router;
