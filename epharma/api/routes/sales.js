const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Sale = require("../models/sale");
const Product = require("../models/product");
const { logActivity } = require("../utils/activityLogger");

// Ajouter une vente
router.post("/", async (req, res) => {
  try {
    const { items, client, pharmacist, invoiceNumber, discount, tax, notes, paymentMethod } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: "Aucun article de vente fourni" });
    }

    if (!mongoose.Types.ObjectId.isValid(client)) {
      return res.status(400).json({ success: false, message: "ID client invalide" });
    }


    let subtotal = 0;
    const processedItems = [];

    for (const item of items) {
      if (!mongoose.Types.ObjectId.isValid(item.product)) {
        return res.status(400).json({ success: false, message: `ID produit invalide pour l'article: ${item.product}` });
      }

      const product = await Product.findById(item.product);
      if (!product) {
        return res.status(404).json({ success: false, message: `Produit ${item.product} non trouvé` });
      }

      const lot = product.lots.find((lot) => lot.lotNumber === item.lotNumber);
      if (!lot) {
        return res.status(404).json({ success: false, message: `Lot ${item.lotNumber} introuvable pour ${product.name}` });
      }

      if (lot.quantityAvailable < item.quantity) {
        return res.status(400).json({ success: false, message: `Stock insuffisant pour ${product.name} lot ${lot.lotNumber}. Disponible: ${lot.quantityAvailable}, demandé: ${item.quantity}` });
      }

      if (new Date(lot.expirationDate) < new Date()) {
        return res.status(400).json({ success: false, message: `Le lot ${lot.lotNumber} de ${product.name} est expiré` });
      }

      const itemTotal = item.quantity * item.unitPrice;
      subtotal += itemTotal;

      processedItems.push({
        product: product._id,
        lotNumber: lot.lotNumber,
        expirationDate: lot.expirationDate,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: itemTotal
      });

      lot.quantityAvailable -= item.quantity;
      product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
      await product.save();
    }

    const total = subtotal - (discount || 0) + (tax || 0);

    const sale = new Sale({
      client,
      pharmacist,
      invoiceNumber: invoiceNumber || `INV-${Date.now()}`,
      items: processedItems,
      subtotal,
      discount: discount || 0,
      tax: tax || 0,
      total,
      paymentMethod: paymentMethod || 'cash',
      paymentStatus: 'paid',
      status: 'active',
      notes: notes || '',
      saleDate: new Date(),
    });

    const savedSale = await sale.save();
    await savedSale.populate(['client', 'items.product']);

    await logActivity({
      actionType: "création",
      entityType: "vente",
      entityId: savedSale._id.toString(),
      entityName: `Vente #${savedSale._id.toString().slice(-6)}`,
      description: `Vente créée: ${items.length} articles, total: ${total}`,
    });

    res.status(201).json({
      success: true,
      message: "Vente créée avec succès",
      data: savedSale
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ success: false, message: "Erreur de validation", errors });
    }
    res.status(400).json({ success: false, message: error.message });
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
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "ID vente invalide" });
    }

    const sale = await Sale.findById(req.params.id);
    if (!sale) {
      return res.status(404).json({ success: false, message: "Vente introuvable" });
    }

    if (sale.status === 'cancelled') {
      return res.status(400).json({ success: false, message: "Vente déjà annulée" });
    }

    for (const item of sale.items) {
      const product = await Product.findById(item.product);
      if (!product) continue;

      const lot = product.lots.find((lot) => lot.lotNumber === item.lotNumber);
      if (lot) {
        lot.quantityAvailable += item.quantity;
      }
      product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
      await product.save();
    }

    sale.status = 'cancelled';
    await sale.save();
    await sale.populate(['client', 'items.product']);

    await logActivity({
      actionType: "update",
      entityType: "sale",
      entityId: sale._id.toString(),
      entityName: `Sale #${sale._id.toString().slice(-6)}`,
      description: `Sale cancelled: ${sale.items.length} items`,
    });

    res.json({ success: true, message: "Vente annulée avec succès", data: sale });
  } catch (error) {
    res.status(500).json({ success: false, message: "Erreur lors de l'annulation de la vente", error: error.message });
  }
});

module.exports = router;
