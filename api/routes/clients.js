const express = require("express");
const router = express.Router();
const clientController = require("../controllers/clientController");
const authMiddleware = require("../middleware/authMiddleware");
const { isClient, requirePermission } = require("../middleware/roleMiddleware");
const { PERMISSIONS } = require("../utils/rolePermissions");

// Authenticated: Client get own profile (MUST be before /:id routes)
router.get("/me", authMiddleware, isClient, clientController.getMyProfile);

router.get("/", authMiddleware, requirePermission(PERMISSIONS.VIEW_CLIENTS), clientController.getClients);

router.use(authMiddleware);

router.get("/:id", requirePermission(PERMISSIONS.VIEW_CLIENTS), clientController.getClientById);

router.post("/", requirePermission(PERMISSIONS.ADD_CLIENT), clientController.createClient);

router.put("/:id", requirePermission(PERMISSIONS.EDIT_CLIENT), clientController.updateClient);

router.delete("/:id", requirePermission(PERMISSIONS.DELETE_CLIENT), clientController.deleteClient);

module.exports = router;
