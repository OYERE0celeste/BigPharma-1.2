const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Supplier = require("../models/supplier");
const { normalizeSupplierData, transformSupplierResponse } = require("../middleware/dataTransform");
const { logActivity } = require("../utils/activityLogger");

// Appliquer le middleware de transformation des réponses
router.use(transformSupplierResponse);

// Ajouter un fournisseur
router.post("/", async (req, res, next) => {
  try {
    const normalizedData = normalizeSupplierData(req.body);
    normalizedData.companyId = req.user.companyId;

    const supplier = new Supplier(normalizedData);
    const savedSupplier = await supplier.save();

    await logActivity({
      actionType: "create",
      entityType: "supplier",
      entityId: savedSupplier._id.toString(),
      entityName: savedSupplier.name,
      description: `New supplier added: ${savedSupplier.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.status(201).json({ success: true, data: savedSupplier });
  } catch (error) {
    next(error);
  }
});

// Liste des fournisseurs
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const query = { companyId: req.user.companyId };

    const suppliers = await Supplier.find(query)
      .sort({ name: 1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await Supplier.countDocuments(query);

    res.json({ 
      success: true, 
      data: suppliers, 
      pagination: { 
        page: Number(page), 
        limit: Number(limit), 
        total, 
        pages: Math.ceil(total / Number(limit)) 
      } 
    });
  } catch (error) {
    next(error);
  }
});

// Un fournisseur par ID
router.get("/:id", async (req, res, next) => {
  try {
    const supplier = await Supplier.findOne({ _id: req.params.id, companyId: req.user.companyId });
    if (!supplier) {
      return res.status(404).json({ success: false, message: "Fournisseur introuvable", code: "NOT_FOUND" });
    }
    res.json({ success: true, data: supplier });
  } catch (error) {
    next(error);
  }
});

// Modifier un fournisseur
router.put("/:id", async (req, res, next) => {
  try {
    const supplier = await Supplier.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      normalizeSupplierData(req.body),
      { new: true, runValidators: true }
    );
    if (!supplier) {
      return res.status(404).json({ success: false, message: "Fournisseur introuvable", code: "NOT_FOUND" });
    }

    await logActivity({
      actionType: "update",
      entityType: "supplier",
      entityId: supplier._id.toString(),
      entityName: supplier.name,
      description: `Supplier updated: ${supplier.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, data: supplier });
  } catch (error) {
    next(error);
  }
});

// Supprimer un fournisseur
router.delete("/:id", async (req, res, next) => {
  try {
    const deleted = await Supplier.findOneAndDelete({ _id: req.params.id, companyId: req.user.companyId });
    if (!deleted) {
      return res.status(404).json({ success: false, message: "Fournisseur introuvable", code: "NOT_FOUND" });
    }

    await logActivity({
      actionType: "delete",
      entityType: "supplier",
      entityId: deleted._id.toString(),
      entityName: deleted.name,
      description: `Supplier deleted: ${deleted.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Fournisseur supprimé" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;