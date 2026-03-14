const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Supplier = require("../models/supplier");
const { normalizeSupplierData, transformSupplierResponse } = require("../middleware/dataTransform");
const { logActivity } = require("../utils/activityLogger");

// Appliquer le middleware de transformation des réponses
router.use(transformSupplierResponse);

// Ajouter un fournisseur
router.post("/", async (req, res) => {
  try {
    const normalizedData = normalizeSupplierData(req.body);
    const supplier = new Supplier(normalizedData);
    const savedSupplier = await supplier.save();

    await logActivity({
      actionType: "create",
      entityType: "supplier",
      entityId: savedSupplier._id.toString(),
      entityName: savedSupplier.name,
      description: `New supplier added: ${savedSupplier.name}`,
    });

    res.status(201).json(savedSupplier);
  } catch (error) {
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: "Erreur de validation", errors });
    }
    res.status(400).json({ message: error.message });
  }
});

// Liste des fournisseurs
router.get("/", async (req, res) => {
  try {
    const suppliers = await Supplier.find();
    res.json(suppliers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Un fournisseur par ID
router.get("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: "ID fournisseur invalide" });
    }
    const supplier = await Supplier.findById(req.params.id);
    if (!supplier) {
      return res.status(404).json({ message: "Fournisseur introuvable" });
    }
    res.json(supplier);
  } catch (error) {
    res.status(404).json({ message: "Fournisseur introuvable" });
  }
});

// Modifier un fournisseur
router.put("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: "ID fournisseur invalide" });
    }
    const supplier = await Supplier.findByIdAndUpdate(
      req.params.id,
      normalizeSupplierData(req.body),
      { new: true, runValidators: true }
    );
    if (!supplier) {
      return res.status(404).json({ message: "Fournisseur introuvable" });
    }

    await logActivity({
      actionType: "update",
      entityType: "supplier",
      entityId: supplier._id.toString(),
      entityName: supplier.name,
      description: `Supplier updated: ${supplier.name}`,
    });

    res.json(supplier);
  } catch (error) {
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: "Erreur de validation", errors });
    }
    res.status(400).json({ message: error.message });
  }
});

// Supprimer un fournisseur
router.delete("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: "ID fournisseur invalide" });
    }
    const deleted = await Supplier.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: "Fournisseur introuvable" });
    }

    await logActivity({
      actionType: "delete",
      entityType: "supplier",
      entityId: deleted._id.toString(),
      entityName: deleted.name,
      description: `Supplier deleted: ${deleted.name}`,
    });

    res.json({ message: "Fournisseur supprimé" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;