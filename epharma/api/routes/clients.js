const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Client = require("../models/client");

const { normalizeClientData, transformClientResponse } = require("../middleware/dataTransform");
const { logActivity } = require("../utils/activityLogger");

// Appliquer le middleware de transformation
router.use(transformClientResponse);

// Ajouter un client
router.post("/", async (req, res) => {
  try {
    const normalizedData = normalizeClientData(req.body);
    // Mongoose attend Date; normalizeClientData renvoie une ISO string: OK (cast automatique)
    const client = new Client(normalizedData);
    const savedClient = await client.save();

    await logActivity({
      actionType: "create",
      entityType: "client",
      entityId: savedClient._id.toString(),
      entityName: savedClient.fullName,
      description: `New client added: ${savedClient.fullName}`,
    });

    res.status(201).json({
      success: true,
      message: "Client créé avec succès",
      data: savedClient
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: "Erreur de validation",
        errors: errors
      });
    }
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Liste des clients
router.get("/", async (req, res) => {
  try {
    const { page = 1, limit = 10, search, gender, hasMedicalHistory } = req.query;
    
    let query = {};
    
    // Filtrage
    if (gender) query.gender = gender;
    if (hasMedicalHistory !== undefined) {
      query.hasMedicalHistory = hasMedicalHistory === 'true' || hasMedicalHistory === true;
    }
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }
    
    const clients = await Client.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
      
    const total = await Client.countDocuments(query);
    
    res.json({
      success: true,
      message: "Liste des clients récupérée",
      data: clients,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération des clients",
      error: error.message
    });
  }
});

// Un client par ID
router.get("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID client invalide"
      });
    }
    
    const client = await Client.findById(req.params.id);
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable"
      });
    }
    
    res.json({
      success: true,
      message: "Client récupéré avec succès",
      data: client
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération du client",
      error: error.message
    });
  }
});

// Modifier un client
router.put("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID client invalide"
      });
    }
    
    const normalizedData = normalizeClientData(req.body);
    
    const client = await Client.findByIdAndUpdate(
      req.params.id,
      normalizedData,
      { new: true, runValidators: true }
    );
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client information updated: ${client.fullName}`,
    });

    res.json({
      success: true,
      message: "Client modifié avec succès",
      data: client
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: "Erreur de validation",
        errors: errors
      });
    }
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Supprimer un client
router.delete("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID client invalide"
      });
    }
    
    const client = await Client.findByIdAndDelete(req.params.id);
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client deleted: ${client.fullName}`,
    });

    res.json({
      success: true,
      message: "Client supprimé avec succès",
      data: client
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la suppression du client",
      error: error.message
    });
  }
});

module.exports = router;