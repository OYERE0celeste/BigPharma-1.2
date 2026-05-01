const Sale = require("../models/sale");
const Product = require("../models/product");
const Finance = require("../models/finance");
const MouvementStock = require("../models/mouvementStock");
const { logActivity } = require("../utils/activityLogger");
const { runInTransaction } = require("../utils/dbUtils");
const { success, failure } = require("../utils/response");

/**
 * Register a new sale
 */
exports.createSale = async (req, res, next) => {
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
      notes,
    } = req.body;

    const activeProducts = items || req.body.products;

    if (!activeProducts || !Array.isArray(activeProducts) || activeProducts.length === 0) {
      return failure(res, { status: 400, message: "Le panier est vide ou invalide" });
    }

    const savedSale = await runInTransaction(async (session) => {
      // 1. Check availability
      for (const item of activeProducts) {
        const prodId = item.product || item.productId;
        const product = await Product.findOne({
          _id: prodId,
          isActive: true,
        }).session(session);

        if (!product) {
          throw new Error(`Produit ${prodId} introuvable`);
        }

        if (product.stockQuantity < item.quantity) {
          throw new Error(`Stock insuffisant pour ${product.name}`);
        }
      }

      const calculatedSubtotal = activeProducts.reduce(
        (sum, item) => sum + (item.total || item.subtotal || item.unitPrice * item.quantity),
        0
      );
      const calculatedTotal = calculatedSubtotal - discount + tax;

      // 2. Create Sale
      const sale = new Sale({
        invoiceNumber: invoiceNumber || `INV-${Date.now()}`,
        client: client || req.body.clientId,
        pharmacist: pharmacist || req.user.fullName,
        items: activeProducts.map((item) => ({
          product: item.product || item.productId,
          lotNumber: item.lotNumber,
          expirationDate: item.expirationDate,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          total: item.total || item.subtotal || item.unitPrice * item.quantity,
        })),
        subtotal: calculatedSubtotal,
        tax: tax,
        discount: discount,
        total: totalAmount || calculatedTotal,
        paymentMethod: paymentMethod || "cash",
        amountReceived: amountReceived || totalAmount || calculatedTotal,
        notes: notes || "Vente POS",
        companyId: req.user.companyId,
      });

      const confirmedSale = await sale.save({ session });

      // 3. Stock deduction (Prioritize selected lot, then FIFO if needed)
      for (const item of activeProducts) {
        const prodId = item.product || item.productId;
        const product = await Product.findOne({ _id: prodId }).session(session);

        if (!product) continue;

        let remaining = item.quantity;

        // 1. Try to deduct from the selected lot first if provided
        if (item.lotNumber) {
          const selectedLot = product.lots.find((l) => l.lotNumber === item.lotNumber);
          if (selectedLot && selectedLot.quantityAvailable > 0) {
            const subtract = Math.min(selectedLot.quantityAvailable, remaining);
            const before = selectedLot.quantityAvailable;
            selectedLot.quantityAvailable -= subtract;
            remaining -= subtract;

            if (subtract > 0) {
              await new MouvementStock({
                produitId: product._id,
                lotNumber: selectedLot.lotNumber,
                type: "sortie",
                quantite: subtract,
                beforeQuantity: before,
                afterQuantity: selectedLot.quantityAvailable,
                reason: "vente",
                referenceId: confirmedSale._id,
                utilisateur: req.user.fullName,
                companyId: req.user.companyId,
              }).save({ session });
            }
          }
        }

        // 2. If still remaining, use FIFO on other lots
        if (remaining > 0) {
          const otherLots = product.lots
            .filter((l) => l.quantityAvailable > 0 && l.lotNumber !== item.lotNumber)
            .sort((a, b) => new Date(a.expirationDate) - new Date(b.expirationDate));

          for (const lot of otherLots) {
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
        }

        // Ensure Mongoose tracks changes in the lots array
        product.markModified("lots");
        // stockQuantity will be updated by pre-save hook in product.js
        await product.save({ session });
      }

      // 4. Record in Finance
      await new Finance({
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
      }).save({ session });

      // 5. Log Activity
      await logActivity({
        actionType: "create",
        entityType: "sale",
        entityId: confirmedSale._id.toString(),
        entityName: `Vente ${confirmedSale.invoiceNumber}`,
        description: `Vente de ${confirmedSale.total} FCFA`,
        companyId: req.user.companyId,
        user: req.user.fullName,
        clientOrSupplierName: confirmedSale.client,
        totalAmount: confirmedSale.total,
        quantity: confirmedSale.items.reduce((sum, item) => sum + item.quantity, 0),
        paymentMethod: confirmedSale.paymentMethod,
        status: "completed",
        listOfItems: confirmedSale.items.map((item) => ({
          productName: item.productName || "Produit", // Should ideally have name
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.total,
        })),
      });

      return confirmedSale;
    });

    return success(res, { status: 201, data: savedSale });
  } catch (error) {
    next(error);
  }
};

/**
 * Cancel a sale
 */
exports.cancelSale = async (req, res, next) => {
  try {
    const result = await runInTransaction(async (session) => {
      const sale = await Sale.findOne({
        _id: req.params.id,
        companyId: req.user.companyId,
      }).session(session);
      if (!sale || sale.status === "cancelled")
        throw new Error("Vente introuvable ou déjà annulée");

      sale.status = "cancelled";
      await sale.save({ session });

      // Put stock back
      for (const item of sale.items) {
        const product = await Product.findOne({
          _id: item.product,
          companyId: req.user.companyId,
        }).session(session);
        if (product && product.lots.length > 0) {
          const lot = product.lots[0]; // Put back into the first lot for simplicity or implement full reversal
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

          product.stockQuantity = (product.lots || []).reduce(
            (sum, l) => sum + (l.quantityAvailable || 0),
            0
          );
          await product.save({ session });
        }
      }

      // Record refund in Finance
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

      // 6. Log Activity
      await logActivity({
        actionType: "delete",
        entityType: "sale",
        entityId: sale._id.toString(),
        entityName: `Annulation ${sale.invoiceNumber}`,
        description: `Annulation de la vente #${sale.invoiceNumber} (${sale.total} FCFA)`,
        companyId: req.user.companyId,
        user: req.user.fullName,
        clientOrSupplierName: sale.client,
        totalAmount: sale.total,
        quantity: sale.items.reduce((sum, item) => sum + item.quantity, 0),
        paymentMethod: sale.paymentMethod,
        status: "cancelled",
        listOfItems: sale.items.map((item) => ({
          productName: item.productName || "Produit",
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.total,
        })),
      });

      return sale;
    });
    return success(res, { data: result });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all sales
 */
exports.getSales = async (req, res, next) => {
  try {
    const sales = await Sale.find({ companyId: req.user.companyId })
      .populate("client", "fullName")
      .sort({ createdAt: -1 });
    return success(res, { data: sales });
  } catch (error) {
    next(error);
  }
};
