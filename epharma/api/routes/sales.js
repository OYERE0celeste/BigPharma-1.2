const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Sale = require("../models/sale");
const Product = require("../models/product");
const { logActivity } = require("../utils/activityLogger");

// Ajouter une vente
router.post("/", async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { items, ...saleData } = req.body;
    
    // Validate and calculate totals
    let subtotal = 0;
    const processedItems = [];
    
    for (const item of items) {
      const product = await Product.findById(item.product).session(session);
      if (!product) {
        throw new Error(`Product ${item.product} not found`);
      }
      
      if (product.stockQuantity < item.quantity) {
        throw new Error(`Insufficient stock for ${product.name}. Available: ${product.stockQuantity}, Requested: ${item.quantity}`);
      }
      
      const itemTotal = item.quantity * product.price;
      subtotal += itemTotal;
      
      processedItems.push({
        product: product._id,
        quantity: item.quantity,
        unitPrice: product.price,
        total: itemTotal
      });
      
      // Update stock
      await Product.findByIdAndUpdate(
        product._id,
        { $inc: { stockQuantity: -item.quantity } },
        { session }
      );
    }
    
    const total = subtotal - (saleData.discount || 0) + (saleData.tax || 0);
    
    const sale = new Sale({
      ...saleData,
      items: processedItems,
      subtotal,
      total
    });
    
    const savedSale = await sale.save({ session });
    await savedSale.populate(['client', 'items.product']);

    await logActivity({
      actionType: "create",
      entityType: "sale",
      entityId: savedSale._id.toString(),
      entityName: `Sale #${savedSale._id.toString().slice(-6)}`,
      description: `New sale created: ${items.length} items, total: ${total}`,
    });

    await session.commitTransaction();

    res.status(201).json({
      success: true,
      message: "Vente créée avec succès",
      data: savedSale
    });
  } catch (error) {
    await session.abortTransaction();
    
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
  } finally {
    session.endSession();
  }
});

// Liste des ventes
router.get("/", async (req, res) => {
  try {
    const { page = 1, limit = 10, clientId, status, paymentStatus, startDate, endDate } = req.query;
    
    let query = {};
    
    // Filtrage
    if (clientId) query.client = clientId;
    if (status) query.status = status;
    if (paymentStatus) query.paymentStatus = paymentStatus;
    if (startDate || endDate) {
      query.saleDate = {};
      if (startDate) query.saleDate.$gte = new Date(startDate);
      if (endDate) query.saleDate.$lte = new Date(endDate);
    }
    
    const sales = await Sale.find(query)
      .populate('client', 'fullName phone')
      .populate('items.product', 'name price')
      .sort({ saleDate: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
      
    const total = await Sale.countDocuments(query);
    
    res.json({
      success: true,
      message: "Liste des ventes récupérée",
      data: sales,
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
      message: "Erreur lors de la récupération des ventes",
      error: error.message
    });
  }
});

// Une vente par ID
router.get("/:id", async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID vente invalide"
      });
    }
    
    const sale = await Sale.findById(req.params.id)
      .populate('client', 'fullName phone address')
      .populate('items.product', 'name price description');
    
    if (!sale) {
      return res.status(404).json({
        success: false,
        message: "Vente introuvable"
      });
    }
    
    res.json({
      success: true,
      message: "Vente récupérée avec succès",
      data: sale
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération de la vente",
      error: error.message
    });
  }
});

// Annuler une vente
router.patch("/:id/cancel", async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "ID vente invalide"
      });
    }
    
    const sale = await Sale.findById(req.params.id).session(session);
    
    if (!sale) {
      return res.status(404).json({
        success: false,
        message: "Vente introuvable"
      });
    }
    
    if (sale.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: "Vente déjà annulée"
      });
    }
    
    // Restore stock
    for (const item of sale.items) {
      await Product.findByIdAndUpdate(
        item.product,
        { $inc: { stockQuantity: item.quantity } },
        { session }
      );
    }
    
    // Update sale status
    sale.status = 'cancelled';
    await sale.save({ session });
    
    await sale.populate(['client', 'items.product']);

    await logActivity({
      actionType: "update",
      entityType: "sale",
      entityId: sale._id.toString(),
      entityName: `Sale #${sale._id.toString().slice(-6)}`,
      description: `Sale cancelled: ${sale.items.length} items`,
    });

    await session.commitTransaction();

    res.json({
      success: true,
      message: "Vente annulée avec succès",
      data: sale
    });
  } catch (error) {
    await session.abortTransaction();
    res.status(500).json({
      success: false,
      message: "Erreur lors de l'annulation de la vente",
      error: error.message
    });
  } finally {
    session.endSession();
  }
});

module.exports = router;
