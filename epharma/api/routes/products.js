const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Product = require("../models/product");
const { logActivity } = require("../utils/activityLogger");

// Ajouter un produit
router.post("/", async (req, res, next) => {
  try {
    const productData = { ...req.body, companyId: req.user.companyId };
    const product = new Product(productData);
    const savedProduct = await product.save();

    await logActivity({
      actionType: "create",
      entityType: "product",
      entityId: savedProduct._id.toString(),
      entityName: savedProduct.name,
      description: `New product added: ${savedProduct.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.status(201).json({
      success: true,
      message: "Produit créé avec succès",
      data: savedProduct
    });
  } catch (error) {
    next(error);
  }
});

// Liste des produits
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 10, search, category, stockStatus } = req.query;
    
    let query = { isActive: true, companyId: req.user.companyId };
    
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
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    
    const products = await Product.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
      
    const total = await Product.countDocuments(query);
    
    res.json({
      success: true,
      data: products,
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

// Un produit par ID
router.get("/:id", async (req, res, next) => {
  try {
    const product = await Product.findOne({ _id: req.params.id, companyId: req.user.companyId });
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable",
        code: "NOT_FOUND"
      });
    }
    
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
});

// Modifier un produit
router.put("/:id", async (req, res, next) => {
  try {
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Product updated: ${product.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({
      success: true,
      message: "Produit modifié avec succès",
      data: product
    });
  } catch (error) {
    next(error);
  }
});

// Mettre à jour le stock
router.patch("/:id/stock", async (req, res, next) => {
  try {
    const { quantity, operation } = req.body;
    
    if (!quantity || !operation || !['add', 'subtract', 'set'].includes(operation)) {
      return res.status(400).json({
        success: false,
        message: "Quantité et opération requises (add, subtract, set)",
        code: "INVALID_INPUT"
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
    
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      updateQuery,
      { new: true, runValidators: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Stock updated for ${product.name}: ${product.stockQuantity} units`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({
      success: true,
      message: "Stock mis à jour avec succès",
      data: product
    });
  } catch (error) {
    next(error);
  }
});

// Supprimer un produit
router.delete("/:id", async (req, res, next) => {
  try {
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      { isActive: false },
      { new: true }
    );
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produit introuvable",
        code: "NOT_FOUND"
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Product deleted: ${product.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Produit supprimé avec succès" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
