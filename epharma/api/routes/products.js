const express = require("express");
const router = express.Router();
const Product = require("../models/product");
const mongoose = require("mongoose");
const { logActivity } = require("../utils/activityLogger");
const { runInTransaction } = require("../utils/dbUtils");
const MouvementStock = require("../models/mouvementStock");

// Helper pour renvoyer une erreur sans utiliser next()
const sendError = (res, error, message) => {
  console.error(`${message}:`, error);
  res.status(400).json({
    success: false,
    message: message || "Erreur serveur",
    error: error.message
  });
};

// Ajouter un produit
router.post("/", async (req, res) => {
  try {
    const { name, purchasePrice, supplier, lots, sku } = req.body;
    
    const result = await runInTransaction(async (session) => {
      // Normalisation pour recherche fiable
      const normalizedName = name ? name.trim() : "";
      const normalizedSupplier = supplier ? supplier.trim() : "";

      // 1. Recherche de doublon
      let query = { companyId: req.user.companyId, isActive: true };
      if (sku) {
        query.sku = sku;
      } else {
        query.name = new RegExp(`^${normalizedName}$`, 'i');
        query.purchasePrice = purchasePrice;
        query.supplier = new RegExp(`^${normalizedSupplier}$`, 'i');
      }

      let product = await Product.findOne(query).session(session);
      let isNew = false;
      let beforeTotal = 0;

      if (product) {
        // FUSION : Le produit existe, on ajoute les lots
        beforeTotal = product.stockQuantity;
        
        if (lots && Array.isArray(lots)) {
          for (const newLot of lots) {
            const existingLot = product.lots.find(l => 
              l.lotNumber === newLot.lotNumber && 
              new Date(l.expirationDate).getTime() === new Date(newLot.expirationDate).getTime()
            );

            if (existingLot) {
              const beforeLotQty = existingLot.quantityAvailable;
              existingLot.quantityAvailable += newLot.quantityAvailable;
              existingLot.quantity += newLot.quantity; 
              
              await new MouvementStock({
                produitId: product._id,
                lotNumber: existingLot.lotNumber,
                type: "entrée",
                quantite: newLot.quantityAvailable,
                beforeQuantity: beforeLotQty,
                afterQuantity: existingLot.quantityAvailable,
                reason: "achat",
                utilisateur: req.user.fullName,
                companyId: req.user.companyId,
              }).save({ session });
            } else {
              product.lots.push(newLot);
              
              await new MouvementStock({
                produitId: product._id,
                lotNumber: newLot.lotNumber,
                type: "entrée",
                quantite: newLot.quantityAvailable,
                beforeQuantity: 0,
                afterQuantity: newLot.quantityAvailable,
                reason: "achat",
                utilisateur: req.user.fullName,
                companyId: req.user.companyId,
              }).save({ session });
            }
          }
        }
        
        Object.assign(product, req.body);
        product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
        await product.save({ session });
      } else {
        isNew = true;
        const productData = { ...req.body, companyId: req.user.companyId };
        product = new Product(productData);
        const savedProduct = await product.save({ session });
        
        if (lots && Array.isArray(lots)) {
          for (const lot of lots) {
            await new MouvementStock({
              produitId: savedProduct._id,
              lotNumber: lot.lotNumber,
              type: "entrée",
              quantite: lot.quantityAvailable,
              beforeQuantity: 0,
              afterQuantity: lot.quantityAvailable,
              reason: "achat",
              utilisateur: req.user.fullName,
              companyId: req.user.companyId,
            }).save({ session });
          }
        }
      }

      await logActivity({
        actionType: isNew ? "create" : "update",
        entityType: "product",
        entityId: product._id.toString(),
        entityName: product.name,
        description: isNew ? `Nouveau produit créé: ${product.name}` : `Produit fusionné/mis à jour: ${product.name} (Stock: ${beforeTotal} -> ${product.stockQuantity})`,
        companyId: req.user.companyId,
        user: req.user.fullName,
      });

      return { product, isNew };
    });

    res.status(result.isNew ? 201 : 200).json({
      success: true,
      message: result.isNew ? "Produit créé avec succès" : "Produit existant mis à jour (fusion)",
      data: result.product
    });
  } catch (error) {
    sendError(res, error, "Erreur lors de l'ajout du produit");
  }
});

// Liste des produits
router.get("/", async (req, res) => {
  try {
    const { page = 1, limit = 10, search, category, stockStatus } = req.query;
    
    let query = { isActive: true, companyId: req.user.companyId };
    
    // Filtrage
    if (category) query.category = category;
    
    const now = new Date();
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(now.getDate() + 30);

    if (stockStatus) {
      if (stockStatus === 'out_of_stock') {
        query.stockQuantity = 0;
      } else if (stockStatus === 'low_stock') {
        query.$expr = { $lte: ["$stockQuantity", "$minStockLevel"] };
        query.stockQuantity = { $gt: 0 };
      } else if (stockStatus === 'expired') {
        query["lots.expirationDate"] = { $lt: now };
      } else if (stockStatus === 'near_expiration') {
        query["lots.expirationDate"] = { $gte: now, $lte: thirtyDaysFromNow };
      }
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { supplier: { $regex: search, $options: 'i' } },
        { sku: { $regex: search, $options: 'i' } }
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
    sendError(res, error, "Erreur lors de la récupération des produits");
  }
});

// Un produit par ID
router.get("/:id", async (req, res) => {
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
    sendError(res, error, "Erreur lors de la récupération du produit");
  }
});

// Modifier un produit
router.put("/:id", async (req, res) => {
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
    sendError(res, error, "Erreur lors de la modification du produit");
  }
});

// Mettre à jour le stock
router.patch("/:id/stock", async (req, res) => {
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
    sendError(res, error, "Erreur lors de la mise à jour du stock");
  }
});

// Supprimer un produit
router.delete("/:id", async (req, res) => {
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
    sendError(res, error, "Erreur lors de la suppression du produit");
  }
});

// Export de l'inventaire en CSV
router.get("/export/inventory", async (req, res) => {
  try {
    const products = await Product.find({ companyId: req.user.companyId, isActive: true });
    
    let csv = "Nom,SKU,Categorie,Fournisseur,Stock Total,Seuil Min,Status Expiration,Lot,Quantite Lot,Expiration\n";
    
    for (const p of products) {
      if (p.lots && p.lots.length > 0) {
        for (const lot of p.lots) {
          csv += `"${p.name}","${p.sku || ''}","${p.category}","${p.supplier || ''}",${p.stockQuantity},${p.minStockLevel},"${p.expirationStatus}","${lot.lotNumber}",${lot.quantityAvailable},"${lot.expirationDate.toISOString().split('T')[0]}"\n`;
        }
      } else {
        csv += `"${p.name}","${p.sku || ''}","${p.category}","${p.supplier || ''}",${p.stockQuantity},${p.minStockLevel},"${p.expirationStatus}","N/A",0,"N/A"\n`;
      }
    }

    res.header("Content-Type", "text/csv");
    res.attachment(`inventaire_bigpharma_${Date.now()}.csv`);
    return res.send(csv);
  } catch (error) {
    sendError(res, error, "Erreur lors de l'export CSV");
  }
});

module.exports = router;
