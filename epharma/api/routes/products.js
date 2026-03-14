const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Product = require("../models/product");
const { logActivity } = require("../utils/activityLogger");

// Ajouter un produit
router.post("/", async (req, res) => {
  try {
    console.log('POST /api/products body:', JSON.stringify(req.body));
    const product = new Product(req.body);
    const savedProduct = await product.save();

    await logActivity({
      actionType: "create",
      entityType: "product",
      entityId: savedProduct._id.toString(),
      entityName: savedProduct.name,
      description: `New product added: ${savedProduct.name}`,
    });

    res.status(201).json({
      success: true,
      message: "Produit créé avec succès",
      data: savedProduct
    });
  } catch (error) {
    console.error('POST /api/products fatal error', error);
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: "Erreur de validation",
        errors: errors
      });
    }
    res.status(500).json({
      success: false,
      message: error.message || 'Erreur interne',
      stack: error.stack,
    });
  }
});

// Liste des produits
router.get("/", async (req, res) => {
  try {
    const { page = 1, limit = 10, search, category, stockStatus } = req.query;
    
    let query = { isActive: true };
    
    // Filtrage
    if (category) query.category = category;
    if (stockStatus) {
      if (stockStatus === 'out_of_stock') {
        query.stockQuantity = 0;
      } else if (stockStatus === 'low_stock') {
        query.$expr = { $lte: ["$stockQuantity", "$minStockLevel"] };
        query.stockQuantity = { $gt: 0 };
      }
    }
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { manufacturer: { $regex: search, $options: 'i' } }
      ];
    }
    
    const products = await Product.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
      
    const total = await Product.countDocuments(query);
    
    res.json({
      success: true,
      message: "Liste des produits récupérée",
      data: products,
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
      message: "Erreur lors de la récupération des produits",
      error: error.message
    });
  }
});

// Un produit par ID
router.get("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID produit invalide"
      });
    }
    
    const product = await Product.findById(req.params.id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable"
      });
    }
    
    res.json({
      success: true,
      message: "Produit récupéré avec succès",
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération du produit",
      error: error.message
    });
  }
});

// Modifier un produit
router.put("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID produit invalide"
      });
    }
    
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Product updated: ${product.name}`,
    });

    res.json({
      success: true,
      message: "Produit modifié avec succès",
      data: product
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

// Mettre à jour le stock
router.patch("/:id/stock", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID produit invalide"
      });
    }

    const { quantity, operation } = req.body;
    
    if (!quantity || !operation || !['add', 'subtract', 'set'].includes(operation)) {
      return res.status(400).json({
        success: false,
        message: "Quantité et opération requises (add, subtract, set)"
      });
    }

    let updateQuery = {};
    if (operation === 'set') {
      updateQuery.stockQuantity = quantity;
    } else if (operation === 'add') {
      updateQuery.$inc = { stockQuantity: quantity };
    } else if (operation === 'subtract') {
      updateQuery.$inc = { stockQuantity: -quantity };
    }
    
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      updateQuery,
      { new: true, runValidators: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Stock updated for ${product.name}: ${product.stockQuantity} units`,
    });

    res.json({
      success: true,
      message: "Stock mis à jour avec succès",
      data: product
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Supprimer un produit
router.delete("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID produit invalide"
      });
    }
    
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Product deleted: ${product.name}`,
    });

    res.json({
      success: true,
      message: "Produit supprimé avec succès",
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la suppression du produit",
      error: error.message
    });
  }
});

module.exports = router;
