const Product = require("../models/product");
const MouvementStock = require("../models/mouvementStock");
const { logActivity } = require("../utils/activityLogger");
const { runInTransaction } = require("../utils/dbUtils");
const { success, failure } = require("../utils/response");

const buildProductPayload = (body = {}) => {
  const allowedFields = [
    "name",
    "category",
    "description",
    "barcode",
    "prescriptionRequired",
    "purchasePrice",
    "sellingPrice",
    "lowStockThreshold",
    "minStockLevel",
    "stockQuantity",
    "lots",
    "isActive",
  ];

  return allowedFields.reduce((payload, field) => {
    if (body[field] !== undefined) {
      payload[field] = body[field];
    }
    return payload;
  }, {});
};

/**
 * Get all products (with filters and pagination)
 * Global visibility by default.
 */
exports.getProducts = async (req, res, next) => {
  try {
    const { page = 1, limit = 10, search, category, stockStatus, companyId } = req.query;

    let query = { isActive: true };

    if (companyId) {
      query.companyId = companyId;
    }

    // Category filtering
    if (category) query.category = category;

    const now = new Date();
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(now.getDate() + 30);

    // Stock status filtering
    if (stockStatus) {
      if (stockStatus === "out_of_stock") {
        query.stockQuantity = 0;
      } else if (stockStatus === "low_stock") {
        query.$expr = { $lte: ["$stockQuantity", "$minStockLevel"] };
        query.stockQuantity = { $gt: 0 };
      } else if (stockStatus === "expired") {
        query["lots.expirationDate"] = { $lt: now };
      } else if (stockStatus === "near_expiration") {
        query["lots.expirationDate"] = { $gte: now, $lte: thirtyDaysFromNow };
      }
    }

    // Search filtering
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    const products = await Product.find(query)
      .populate("companyId", "name email")
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Product.countDocuments(query);

    return success(res, {
      data: products,
      extra: {
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get a single product by ID
 */
exports.getProductById = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id).populate("companyId", "name email");

    if (!product || !product.isActive) {
      return failure(res, {
        status: 404,
        message: "Produit introuvable",
      });
    }

    return success(res, { data: product });
  } catch (error) {
    next(error);
  }
};

/**
 * Create or Update (Fusion) a product
 */
exports.createProduct = async (req, res, next) => {
  try {
    const productPayload = buildProductPayload(req.body);
    const { name, purchasePrice, lots } = productPayload;

    const result = await runInTransaction(async (session) => {
      const normalizedName = name ? name.trim() : "";

      const query = {
        companyId: req.user.companyId,
        isActive: true,
        name: new RegExp(`^${normalizedName}$`, "i"),
        purchasePrice,
      };

      let product = await Product.findOne(query).session(session);
      let isNew = false;
      let beforeTotal = 0;

      if (product) {
        beforeTotal = product.stockQuantity;

        if (lots && Array.isArray(lots)) {
          for (const newLot of lots) {
            const existingLot = product.lots.find(
              (l) =>
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

        Object.assign(product, productPayload);
        product.stockQuantity = product.lots.reduce(
          (sum, l) => sum + (l.quantityAvailable || 0),
          0
        );
        await product.save({ session });
      } else {
        isNew = true;
        const productData = { ...productPayload, companyId: req.user.companyId };
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
        description: isNew
          ? `Nouveau produit créé: ${product.name}`
          : `Produit fusionné/mis à jour: ${product.name} (Stock: ${beforeTotal} -> ${product.stockQuantity})`,
        companyId: req.user.companyId,
        user: req.user.fullName,
        productName: product.name,
        quantity: isNew ? product.stockQuantity : product.stockQuantity - beforeTotal,
        totalAmount:
          (isNew ? product.stockQuantity : product.stockQuantity - beforeTotal) *
          product.purchasePrice,
        status: "completed",
      });

      return { product, isNew };
    });

    return success(res, {
      status: result.isNew ? 201 : 200,
      data: result.product,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a product
 */
exports.updateProduct = async (req, res, next) => {
  try {
    const productPayload = buildProductPayload(req.body);
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      productPayload,
      { new: true, runValidators: true }
    );

    if (!product) {
      return failure(res, {
        status: 404,
        message: "Produit introuvable",
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Produit mis à jour: ${product.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { data: product });
  } catch (error) {
    next(error);
  }
};

/**
 * Update stock for a product
 */
exports.updateStock = async (req, res, next) => {
  try {
    const { quantity, operation } = req.body;

    if (!quantity || !operation || !["add", "subtract", "set"].includes(operation)) {
      return failure(res, {
        status: 400,
        message: "Quantité et opération requises (add, subtract, set)",
      });
    }

    let updateQuery = {};
    if (operation === "set") {
      updateQuery.stockQuantity = quantity;
    } else if (operation === "add") {
      updateQuery.$inc = { stockQuantity: quantity };
    } else if (operation === "subtract") {
      updateQuery.$inc = { stockQuantity: -quantity };
    }

    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      updateQuery,
      { new: true, runValidators: true }
    );

    if (!product) {
      return failure(res, {
        status: 404,
        message: "Produit introuvable",
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Stock mis à jour pour ${product.name}: ${product.stockQuantity} unités`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { data: product });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete (deactivate) a product
 */
exports.deleteProduct = async (req, res, next) => {
  try {
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      { isActive: false },
      { new: true }
    );

    if (!product) {
      return failure(res, {
        status: 404,
        message: "Produit introuvable",
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "product",
      entityId: product._id.toString(),
      entityName: product.name,
      description: `Produit supprimé (désactivé): ${product.name}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { data: { message: "Produit supprimé avec succès" } });
  } catch (error) {
    next(error);
  }
};

/**
 * Export inventory as CSV
 */
exports.exportInventory = async (req, res, next) => {
  try {
    const products = await Product.find({ isActive: true });

    let csv = "Nom,Categorie,Stock Total,Seuil Min,Status Expiration,Lot,Quantite Lot,Expiration\n";

    for (const p of products) {
      if (p.lots && p.lots.length > 0) {
        for (const lot of p.lots) {
          csv += `"${p.name}","${p.category}",${p.stockQuantity},${p.minStockLevel},"${p.expirationStatus}","${lot.lotNumber}",${lot.quantityAvailable},"${lot.expirationDate.toISOString().split("T")[0]}"\n`;
        }
      } else {
        csv += `"${p.name}","${p.category}",${p.stockQuantity},${p.minStockLevel},"${p.expirationStatus}","N/A",0,"N/A"\n`;
      }
    }

    res.header("Content-Type", "text/csv");
    res.attachment(`inventaire_bigpharma_${Date.now()}.csv`);
    return res.send(csv);
  } catch (error) {
    next(error);
  }
};
