const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Consultation = require("../models/consultation");
const { logActivity } = require("../utils/activityLogger");

// Ajouter une consultation
router.post("/", async (req, res) => {
  try {
    const consultation = new Consultation(req.body);
    const savedConsultation = await consultation.save();
    await savedConsultation.populate('client', 'fullName phone');

    await logActivity({
      actionType: "create",
      entityType: "consultation",
      entityId: savedConsultation._id.toString(),
      entityName: `Consultation for ${savedConsultation.client.fullName}`,
      description: `New consultation registered for ${savedConsultation.client.fullName}`,
    });

    res.status(201).json({
      success: true,
      message: "Consultation créée avec succès",
      data: savedConsultation
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

// Liste des consultations
router.get("/", async (req, res) => {
  try {
    const { page = 1, limit = 10, search, clientId, status, startDate, endDate } = req.query;
    
    let query = {};
    
    // Filtrage
    if (clientId) query.client = clientId;
    if (status) query.status = status;
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }
    
    const consultations = await Consultation.find(query)
      .populate('client', 'fullName phone')
      .sort({ date: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
      
    const total = await Consultation.countDocuments(query);
    
    res.json({
      success: true,
      message: "Liste des consultations récupérée",
      data: consultations,
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
      message: "Erreur lors de la récupération des consultations",
      error: error.message
    });
  }
});

// Une consultation par ID
router.get("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID consultation invalide"
      });
    }
    
    const consultation = await Consultation.findById(req.params.id)
      .populate('client', 'fullName phone dateOfBirth address gender');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable"
      });
    }
    
    res.json({
      success: true,
      message: "Consultation récupérée avec succès",
      data: consultation
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération de la consultation",
      error: error.message
    });
  }
});

// Modifier une consultation
router.put("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID consultation invalide"
      });
    }
    
    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('client', 'fullName phone');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "consultation",
      entityId: consultation._id.toString(),
      entityName: `Consultation for ${consultation.client.fullName}`,
      description: `Consultation updated for ${consultation.client.fullName}`,
    });

    res.json({
      success: true,
      message: "Consultation modifiée avec succès",
      data: consultation
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

// Supprimer une consultation
router.delete("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID consultation invalide"
      });
    }
    
    const consultation = await Consultation.findByIdAndDelete(req.params.id)
      .populate('client', 'fullName phone');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "consultation",
      entityId: consultation._id.toString(),
      entityName: `Consultation for ${consultation.client.fullName}`,
      description: `Consultation deleted for ${consultation.client.fullName}`,
    });

    res.json({
      success: true,
      message: "Consultation supprimée avec succès",
      data: consultation
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la suppression de la consultation",
      error: error.message
    });
  }
});

module.exports = router;
