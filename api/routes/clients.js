const express = require("express");
const router = express.Router();
const clientController = require("../controllers/clientController");
const authMiddleware = require("../middleware/authMiddleware");
const optionalAuthMiddleware = require("../middleware/optionalAuthMiddleware");
const { isAdmin, isClient } = require("../middleware/roleMiddleware");

// Authenticated: Client get own profile (MUST be before /:id routes)
router.get("/me", authMiddleware, isClient, clientController.getMyProfile);

// Public: Get all clients for a company (no auth required, company ID in query)
router.get("/", optionalAuthMiddleware, clientController.getClients);

// Admin/Pharmacy staff routes (MUST be after specific routes like /me)
router.use(authMiddleware, isAdmin);

// Get client by ID
router.get("/:id", clientController.getClientById);

// Create new client
router.post("/", clientController.createClient);

// Update client
router.put("/:id", clientController.updateClient);

// Delete client (soft delete)
router.delete("/:id", clientController.deleteClient);

module.exports = router;
