const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Consultation = require("../models/consultation");
const { logActivity } = require("../utils/activityLogger");

// Ajouter une consultation
router.post("/", async (req, res, next) => {
  try {
    const consultationData = { ...req.body, companyId: req.user.companyId };
    
    // Vérifier que le client appartient à la même compagnie
    const Client = require("../models/client");
    const client = await Client.findOne({ _id: consultationData.client, companyId: req.user.companyId });
    if (!client) {
      return res.status(404).json({ success: false, message: "Client introuvable ou non autorisé", code: "NOT_FOUND" });
    }

    const consultation = new Consultation(consultationData);
    const savedConsultation = await consultation.save();
    await savedConsultation.populate('client', 'fullName phone');

    await logActivity({
      actionType: "create",
      entityType: "consultation",
      entityId: savedConsultation._id.toString(),
      entityName: `Consultation for ${savedConsultation.client.fullName}`,
      description: `New consultation registered for ${savedConsultation.client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.status(201).json({
      success: true,
      message: "Consultation créée avec succès",
      data: savedConsultation
    });
  } catch (error) {
    next(error);
  }
});

// Liste des consultations
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 10, clientId, status, startDate, endDate } = req.query;
    
    let query = { companyId: req.user.companyId };
    
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
      data: consultations,
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

// Une consultation par ID
router.get("/:id", async (req, res, next) => {
  try {
    const consultation = await Consultation.findOne({ _id: req.params.id, companyId: req.user.companyId })
      .populate('client', 'fullName phone dateOfBirth address gender');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable",
        code: "NOT_FOUND"
      });
    }
    
    res.json({
      success: true,
      data: consultation
    });
  } catch (error) {
    next(error);
  }
});

// Modifier une consultation
router.put("/:id", async (req, res, next) => {
  try {
    const consultation = await Consultation.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      req.body,
      { new: true, runValidators: true }
    ).populate('client', 'fullName phone');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "consultation",
      entityId: consultation._id.toString(),
      entityName: `Consultation for ${consultation.client.fullName}`,
      description: `Consultation updated for ${consultation.client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({
      success: true,
      message: "Consultation modifiée avec succès",
      data: consultation
    });
  } catch (error) {
    next(error);
  }
});

// Supprimer une consultation
router.delete("/:id", async (req, res, next) => {
  try {
    const consultation = await Consultation.findOneAndDelete({ _id: req.params.id, companyId: req.user.companyId })
      .populate('client', 'fullName phone');
    
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "consultation",
      entityId: consultation._id.toString(),
      entityName: `Consultation for ${consultation.client.fullName}`,
      description: `Consultation deleted for ${consultation.client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Consultation supprimée avec succès" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
