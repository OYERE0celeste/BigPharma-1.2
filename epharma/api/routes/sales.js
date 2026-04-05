const express = require("express");
const router = express.Router();
const Sale = require("../models/sale");
const Product = require("../models/product");
const Finance = require("../models/finance");
const { logActivity } = require("../utils/activityLogger");
const { runInTransaction } = require("../utils/dbUtils");
const MouvementStock = require("../models/mouvementStock");

// Enregistrer une vente (Atomicité & FIFO)
router.post("/", async (req, res) => {
  try {
    const { 
      client, 
      items, 
      totalAmount, 
      paymentMethod, 
      discount = 0, 
      tax = 0,
      invoiceNumber,
      pharmacist,
      amountReceived,
      notes
    } = req.body;

    const activeClientId = client || req.body.clientId;
    const activeProducts = items || req.body.products;

    if (!activeProducts || !Array.isArray(activeProducts) || activeProducts.length === 0) {
      return res.status(400).json({ success: false, message: "Le panier est vide ou invalide" });
    }

    const savedSale = await runInTransaction(async (session) => {
      // 1. Vérifier la disponibilité
      for (const item of activeProducts) {
        const prodId = item.product || item.productId;
        const product = await Product.findOne({
          _id: prodId,
          companyId: req.user.companyId,
          isActive: true
        }).session(session);

        if (!product) {
          throw new Error(`Produit ${prodId} introuvable`);
        }

        if (product.stockQuantity < item.quantity) {
          throw new Error(`Stock insuffisant pour ${product.name}`);
        }
      }

      const calculatedSubtotal = activeProducts.reduce((sum, item) => sum + (item.total || item.subtotal || (item.unitPrice * item.quantity)), 0);
      const calculatedTotal = calculatedSubtotal - discount + tax;

      // 2. Créer la vente
      const sale = new Sale({
        invoiceNumber: invoiceNumber || `INV-${Date.now()}`,
        client: activeClientId,
        pharmacist: pharmacist || req.user.fullName,
        items: activeProducts.map(item => ({
          product: item.product || item.productId,
          lotNumber: item.lotNumber,
          expirationDate: item.expirationDate,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          total: item.total || item.subtotal || (item.unitPrice * item.quantity)
        })),
        subtotal: calculatedSubtotal,
        tax: tax,
        discount: discount,
        total: totalAmount || calculatedTotal,
        paymentMethod: paymentMethod || "cash",
        amountReceived: amountReceived || (totalAmount || calculatedTotal),
        notes: notes || "Vente POS",
        companyId: req.user.companyId,
      });

      const confirmedSale = await sale.save({ session });

      // 3. Stock FIFO
      for (const item of activeProducts) {
        const prodId = item.product || item.productId;
        const product = await Product.findOne({ _id: prodId, companyId: req.user.companyId }).session(session);

        let remaining = item.quantity;
        const sortedLots = product.lots
          .filter(l => l.quantityAvailable > 0)
          .sort((a, b) => new Date(a.expirationDate) - new Date(b.expirationDate));

        for (const lot of sortedLots) {
          if (remaining <= 0) break;
          const subtract = Math.min(lot.quantityAvailable, remaining);
          
          const before = lot.quantityAvailable;
          lot.quantityAvailable -= subtract;
          remaining -= subtract;

          await new MouvementStock({
            produitId: product._id,
            lotNumber: lot.lotNumber,
            type: "sortie",
            quantite: subtract,
            beforeQuantity: before,
            afterQuantity: lot.quantityAvailable,
            reason: "vente",
            referenceId: confirmedSale._id,
            utilisateur: req.user.fullName,
            companyId: req.user.companyId,
          }).save({ session });
        }

        product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
        await product.save({ session });
      }

      // 4. Finance
      const finance = new Finance({
        dateTime: new Date(),
        type: "sale",
        sourceModule: "Sales",
        reference: confirmedSale.invoiceNumber,
        description: `Vente #${confirmedSale.invoiceNumber}`,
        amount: confirmedSale.total,
        isIncome: true,
        paymentMethod: confirmedSale.paymentMethod,
        employeeName: req.user.fullName,
        saleId: confirmedSale._id,
        companyId: req.user.companyId,
      });
      await finance.save({ session });

      // 5. Activity
      await logActivity({
        actionType: "create",
        entityType: "sale",
        entityId: confirmedSale._id.toString(),
        entityName: `Vente ${confirmedSale.invoiceNumber}`,
        description: `Vente de ${confirmedSale.total} FCFA`,
        companyId: req.user.companyId,
        user: req.user.fullName,
      });

      return confirmedSale;
    });

    res.status(201).json({ success: true, message: "Vente réussie", data: savedSale });
  } catch (error) {
    console.error("SALE_ERROR:", error.stack);
    res.status(400).json({ success: false, message: error.message });
  }
});

router.patch("/:id/cancel", async (req, res) => {
  try {
    const result = await runInTransaction(async (session) => {
      const sale = await Sale.findOne({ _id: req.params.id, companyId: req.user.companyId }).session(session);
      if (!sale || sale.status === "cancelled") throw new Error("Vente introuvable ou déjà annulée");

      sale.status = "cancelled";
      await sale.save({ session });

      for (const item of sale.items) {
        const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId }).session(session);
        if (product && product.lots.length > 0) {
          const lot = product.lots[0];
          const before = lot.quantityAvailable;
          lot.quantityAvailable += item.quantity;
          
          await new MouvementStock({
            produitId: product._id,
            lotNumber: lot.lotNumber,
            type: "entrée",
            quantite: item.quantity,
            beforeQuantity: before,
            afterQuantity: lot.quantityAvailable,
            reason: "annulation_vente",
            referenceId: sale._id,
            utilisateur: req.user.fullName,
            companyId: req.user.companyId,
          }).save({ session });

          product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
          await product.save({ session });
        }
      }

      await new Finance({
        dateTime: new Date(),
        type: "refund",
        sourceModule: "Sales",
        reference: sale.invoiceNumber,
        description: `Annulation Vente #${sale.invoiceNumber}`,
        amount: sale.total,
        isIncome: false,
        paymentMethod: sale.paymentMethod,
        employeeName: req.user.fullName,
        saleId: sale._id,
        companyId: req.user.companyId,
      }).save({ session });

      return sale;
    });
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

router.get("/", async (req, res) => {
  try {
    const sales = await Sale.find({ companyId: req.user.companyId }).sort({ createdAt: -1 });
    res.json({ success: true, data: sales });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
