const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Client = require("../models/client");

const { normalizeClientData, transformClientResponse } = require("../middleware/dataTransform");
const { logActivity } = require("../utils/activityLogger");

// Appliquer le middleware de transformation
router.use(transformClientResponse);

// Ajouter un client
router.post("/", async (req, res, next) => {
  try {
    const normalizedData = normalizeClientData(req.body);
    normalizedData.companyId = req.user.companyId; // Force companyId
    
    const client = new Client(normalizedData);
    const savedClient = await client.save();

    await logActivity({
      actionType: "create",
      entityType: "client",
      entityId: savedClient._id.toString(),
      entityName: savedClient.fullName,
      description: `New client added: ${savedClient.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.status(201).json({
      success: true,
      message: "Client créé avec succès",
      data: savedClient
    });
  } catch (error) {
    next(error);
  }
});

// Liste des clients
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 10, search, gender, hasMedicalHistory } = req.query;
    
    let query = { companyId: req.user.companyId };
    
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
      data: clients,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    next(error);
  }
});

// Un client par ID
router.get("/:id", async (req, res, next) => {
  try {
    const client = await Client.findOne({ _id: req.params.id, companyId: req.user.companyId });
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable",
        code: "NOT_FOUND"
      });
    }
    
    res.json({
      success: true,
      data: client
    });
  } catch (error) {
    next(error);
  }
});

// Modifier un client
router.put("/:id", async (req, res, next) => {
  try {
    const normalizedData = normalizeClientData(req.body);
    
    const client = await Client.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      normalizedData,
      { new: true, runValidators: true }
    );
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client information updated: ${client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({
      success: true,
      message: "Client modifié avec succès",
      data: client
    });
  } catch (error) {
    next(error);
  }
});

// Supprimer un client
router.delete("/:id", async (req, res, next) => {
  try {
    const client = await Client.findOneAndDelete({ _id: req.params.id, companyId: req.user.companyId });
    
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client deleted: ${client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Client supprimé avec succès" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;