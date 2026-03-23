const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Sale = require("../models/sale");
const Product = require("../models/product");
const Finance = require("../models/finance");
const { logActivity } = require("../utils/activityLogger");

// Ajouter une vente
router.post("/", async (req, res, next) => {
  try {
    const { items, client: clientId, pharmacist, invoiceNumber, discount, tax, notes, paymentMethod } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: "Aucun article de vente fourni", code: "INVALID_INPUT" });
    }

    // Vérifier que le client appartient à la même compagnie
    const client = await require("../models/client").findOne({ _id: clientId, companyId: req.user.companyId });
    if (!client) {
      return res.status(404).json({ success: false, message: "Client introuvable ou non autorisé", code: "NOT_FOUND" });
    }

    let subtotal = 0;
    const processedItems = [];

    for (const item of items) {
      // Rechercher le produit dans la même compagnie
      const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId });
      if (!product) {
        return res.status(404).json({ success: false, message: `Produit ${item.product} non trouvé ou non autorisé`, code: "NOT_FOUND" });
      }

      const lot = product.lots.find((lot) => lot.lotNumber === item.lotNumber);
      if (!lot) {
        return res.status(404).json({ success: false, message: `Lot ${item.lotNumber} introuvable pour ${product.name}`, code: "NOT_FOUND" });
      }

      if (lot.quantityAvailable < item.quantity) {
        return res.status(400).json({ 
          success: false, 
          message: `Stock insuffisant pour ${product.name} lot ${lot.lotNumber}. Disponible: ${lot.quantityAvailable}, demandé: ${item.quantity}`,
          code: "INSUFFICIENT_STOCK"
        });
      }

      if (new Date(lot.expirationDate) < new Date()) {
        return res.status(400).json({ success: false, message: `Le lot ${lot.lotNumber} de ${product.name} est expiré`, code: "EXPIRED_PRODUCT" });
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
      client: clientId,
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
      companyId: req.user.companyId,
    });

    const savedSale = await sale.save();
    await savedSale.populate(['client', 'items.product']);

    await logActivity({
      actionType: "create",
      entityType: "sale",
      entityId: savedSale._id.toString(),
      entityName: `Vente #${savedSale.invoiceNumber}`,
      description: `Vente créée: ${items.length} articles, total: ${total}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    // Create linked finance transaction
    const financeTransaction = new Finance({
      dateTime: new Date(),
      type: "sale",
      sourceModule: "Ventes",
      reference: savedSale.invoiceNumber,
      description: `Revenu de vente ${savedSale.invoiceNumber}`,
      amount: savedSale.total,
      isIncome: true,
      paymentMethod: savedSale.paymentMethod,
      employeeName: savedSale.pharmacist,
      saleId: savedSale._id,
      companyId: req.user.companyId,
    });
    await financeTransaction.save();

    res.status(201).json({
      success: true,
      message: "Vente créée avec succès",
      data: savedSale
    });
  } catch (error) {
    next(error);
  }
});

// Liste des ventes
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 10, clientId, status, paymentStatus, startDate, endDate } = req.query;
    
    let query = { companyId: req.user.companyId };
    
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
      data: sales,
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

// Une vente par ID
router.get("/:id", async (req, res, next) => {
  try {
    const sale = await Sale.findOne({ _id: req.params.id, companyId: req.user.companyId })
      .populate('client', 'fullName phone address')
      .populate('items.product', 'name price description');
    
    if (!sale) {
      return res.status(404).json({
        success: false,
        message: "Vente introuvable",
        code: "NOT_FOUND"
      });
    }
    
    res.json({
      success: true,
      data: sale
    });
  } catch (error) {
    next(error);
  }
});

// Annuler une vente
router.patch("/:id/cancel", async (req, res, next) => {
  try {
    const sale = await Sale.findOne({ _id: req.params.id, companyId: req.user.companyId });
    if (!sale) {
      return res.status(404).json({ success: false, message: "Vente introuvable", code: "NOT_FOUND" });
    }

    if (sale.status === 'cancelled') {
      return res.status(400).json({ success: false, message: "Vente déjà annulée", code: "ALREADY_CANCELLED" });
    }

    for (const item of sale.items) {
      const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId });
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
    
    await logActivity({
      actionType: "update",
      entityType: "sale",
      entityId: sale._id.toString(),
      entityName: `Sale #${sale.invoiceNumber}`,
      description: `Sale cancelled: ${sale.items.length} items`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Vente annulée avec succès" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
