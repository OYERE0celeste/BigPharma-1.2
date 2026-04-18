const express = require("express");
const authController = require("../controllers/authController");
const authMiddleware = require("../middleware/authMiddleware");
const validate = require("../middleware/validate");
const {
  loginSchema,
  registerSchema,
  registerClientSchema,
  forgotSchema,
  resetSchema,
  updateMeSchema,
  changePasswordSchema,
} = require("../validation/authSchemas");

const router = express.Router();

router.post("/register", validate(registerSchema), authController.register);
router.post("/register-client", validate(registerClientSchema), authController.registerClient);
router.post("/login", validate(loginSchema), authController.login);
router.post("/forgot-password", validate(forgotSchema), authController.forgotPassword);
router.post("/reset-password", validate(resetSchema), authController.resetPassword);

router.use(authMiddleware);

router.get("/me", authController.getMe);
router.put("/me", validate(updateMeSchema), authController.updateMe);
router.post("/change-password", validate(changePasswordSchema), authController.changePassword);

module.exports = router;

