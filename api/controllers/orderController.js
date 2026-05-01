const Client = require("../models/client");
const Order = require("../models/order");
const OrderTimeline = require("../models/orderTimeline");
const Prescription = require("../models/prescription");
const Product = require("../models/product");
const Finance = require("../models/finance");
const { logActivity } = require("../utils/activityLogger");
const { success, failure } = require("../utils/response");

const ORDER_STATUSES = [
  "en_attente",
  "en_preparation",
  "pret_pour_recuperation",
  "validee",
  "annulee",
];

const ORDER_TRANSITIONS = {
  en_attente: ["en_preparation", "pret_pour_recuperation", "validee", "annulee"],
  en_preparation: ["pret_pour_recuperation", "validee", "annulee"],
  pret_pour_recuperation: ["validee", "annulee"],
  validee: [],
  annulee: [],
};

const ORDER_STATUS_LABELS = {
  en_attente: "en attente",
  en_preparation: "en préparation",
  pret_pour_recuperation: "prête pour récupération",
  validee: "validée (récupérée)",
  annulee: "annulée",
};

const generateOrderNumber = async () => {
  const year = new Date().getFullYear();
  const startOfYear = new Date(year, 0, 1);
  const endOfYear = new Date(year, 11, 31, 23, 59, 59);

  const count = await Order.countDocuments({
    createdAt: { $gte: startOfYear, $lte: endOfYear },
  });

  return `CMD-${year}-${String(count + 1).padStart(4, "0")}`;
};

const toPositiveInteger = (value) => {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return null;
  }
  return parsed;
};

const buildOrdersQuery = (query = {}) =>
  Order.find(query)
    .populate("userId", "fullName email phone")
    .populate("clientId", "fullName email phone address userId")
    .populate("prescriptionId", "status imageUrl validatedAt pharmacyNotes")
    .populate("products.productId", "name sellingPrice stockQuantity prescriptionRequired");

const buildOrderQuery = (query = {}) =>
  Order.findOne(query)
    .populate("userId", "fullName email phone")
    .populate("clientId", "fullName email phone address userId")
    .populate("prescriptionId", "status imageUrl validatedAt pharmacyNotes")
    .populate("products.productId", "name sellingPrice stockQuantity prescriptionRequired");

const availableStockForProduct = (product) =>
  (product.lots || []).reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);

const availableOrderableStockForProduct = (product) => {
  const now = new Date();
  return (product.lots || []).reduce((sum, lot) => {
    if (new Date(lot.expirationDate) < now) {
      return sum;
    }
    return sum + (lot.quantityAvailable || 0);
  }, 0);
};

const allocateStock = (product, quantity) => {
  const now = new Date();
  const eligibleLots = [...(product.lots || [])]
    .filter((lot) => (lot.quantityAvailable || 0) > 0 && new Date(lot.expirationDate) >= now)
    .sort((a, b) => new Date(a.expirationDate) - new Date(b.expirationDate));

  let remaining = quantity;
  const lotAllocations = [];

  for (const lot of eligibleLots) {
    if (remaining <= 0) {
      break;
    }

    const usedQuantity = Math.min(lot.quantityAvailable || 0, remaining);
    if (usedQuantity <= 0) {
      continue;
    }

    lot.quantityAvailable -= usedQuantity;
    remaining -= usedQuantity;
    lotAllocations.push({
      lotId: lot._id,
      quantity: usedQuantity,
    });
  }

  if (remaining > 0) {
    throw new Error(`Stock insuffisant pour ${product.name}`);
  }

  product.stockQuantity = availableStockForProduct(product);

  return lotAllocations;
};

const restoreStock = (product, lotAllocations = []) => {
  for (const allocation of lotAllocations) {
    const lot = product.lots.id(allocation.lotId);
    if (lot) {
      lot.quantityAvailable += allocation.quantity;
    }
  }

  product.stockQuantity = availableStockForProduct(product);
};

const resolveClientForUser = async (user) =>
  Client.findOne({
    userId: user._id,
    companyId: user.companyId,
  });

const resolvePrescriptionForOrder = async ({
  prescriptionId,
  userId,
  companyId,
  prescriptionRequired,
}) => {
  if (!prescriptionRequired) {
    return null;
  }

  if (prescriptionId) {
    const providedPrescription = await Prescription.findOne({
      _id: prescriptionId,
      client: userId,
      companyId,
      status: "validated",
    });

    if (!providedPrescription) {
      throw new Error("Ordonnance invalide ou non validée");
    }

    return providedPrescription;
  }

  const latestValidatedPrescription = await Prescription.findOne({
    client: userId,
    companyId,
    status: "validated",
  }).sort({ validatedAt: -1, createdAt: -1 });

  if (!latestValidatedPrescription) {
    throw new Error("Cette commande contient des produits nécessitant une ordonnance valide");
  }

  return latestValidatedPrescription;
};

const computeOrderStats = async (companyId) => {
  const stats = await Promise.all(
    ORDER_STATUSES.map((status) =>
      Order.countDocuments({ companyId, status }).then((count) => [status, count])
    )
  );

  return Object.fromEntries(stats);
};

exports.createOrder = async (req, res, next) => {
  try {
    let rawProducts = req.body.products || req.body.items || [];

    // If it's a string, try to parse it (sometimes happens with some clients/proxies)
    if (typeof rawProducts === "string") {
      try {
        rawProducts = JSON.parse(rawProducts);
      } catch (e) {
        rawProducts = [];
      }
    }

    if (!Array.isArray(rawProducts) || rawProducts.length === 0) {
      console.log("Order creation failed: empty or invalid products list.", {
        body: req.body,
        extracted: rawProducts,
      });
      return failure(res, {
        status: 400,
        message: "La commande doit contenir au moins un article",
      });
    }

    const client = await resolveClientForUser(req.user);
    if (!client) {
      return failure(res, {
        status: 404,
        message: "Profil client introuvable pour cet utilisateur",
      });
    }

    const normalizedProducts = rawProducts.map((item) => ({
      productId: item.productId || item.product || item._id || item.id,
      quantity: toPositiveInteger(item.quantity),
    }));

    if (normalizedProducts.some((item) => !item.productId || item.quantity === null)) {
      return failure(res, {
        status: 400,
        message: "Chaque produit doit contenir productId et une quantité valide",
      });
    }

    const productIds = normalizedProducts.map((item) => String(item.productId));
    if (new Set(productIds).size !== productIds.length) {
      return failure(res, {
        status: 400,
        message: "Un produit ne peut apparaître qu'une seule fois dans la commande",
      });
    }

    const products = await Product.find({
      _id: { $in: productIds },
      companyId: req.user.companyId,
      isActive: true,
    });

    if (products.length !== productIds.length) {
      console.log("Product mismatch details:", {
        userCompanyId: req.user.companyId,
        requestedProductIds: productIds,
        foundProductsCount: products.length,
        foundProductsCompanyIds: products.map((p) => p.companyId),
      });
      return failure(res, {
        status: 404,
        message: "Un ou plusieurs produits de la commande sont introuvables",
      });
    }

    const productsById = new Map(products.map((product) => [String(product._id), product]));

    let totalPrice = 0;
    let prescriptionRequired = false;
    const orderProducts = [];

    for (const requestedProduct of normalizedProducts) {
      const product = productsById.get(String(requestedProduct.productId));
      if (!product) {
        return failure(res, {
          status: 404,
          message: `Produit introuvable : ${requestedProduct.productId}`,
        });
      }

      const currentStock = availableOrderableStockForProduct(product);
      if (currentStock < requestedProduct.quantity) {
        return failure(res, {
          status: 400,
          message: `Stock insuffisant pour ${product.name}`,
        });
      }

      totalPrice += product.sellingPrice * requestedProduct.quantity;
      prescriptionRequired = prescriptionRequired || Boolean(product.prescriptionRequired);

      orderProducts.push({
        productId: product._id,
        name: product.name,
        price: product.sellingPrice,
        quantity: requestedProduct.quantity,
      });
    }

    let prescription = null;
    try {
      prescription = await resolvePrescriptionForOrder({
        prescriptionId: req.body.prescriptionId,
        userId: req.user._id,
        companyId: req.user.companyId,
        prescriptionRequired,
      });
    } catch (error) {
      return failure(res, {
        status: 400,
        message: error.message,
      });
    }

    const order = await Order.create({
      orderNumber: await generateOrderNumber(),
      userId: req.user._id,
      clientId: client._id,
      companyId: req.user.companyId,
      products: orderProducts,
      totalPrice,
      status: "en_attente",
      prescriptionRequired,
      prescriptionId: prescription?._id || null,
      notes: req.body.notes,
    });

    await OrderTimeline.create({
      orderId: order._id,
      status: "en_attente",
      userId: req.user._id,
      note: "Commande créée par le client",
      companyId: req.user.companyId,
    });

    await logActivity({
      actionType: "create",
      entityType: "order",
      entityId: order._id.toString(),
      entityName: order.orderNumber,
      description: `Nouvelle commande ${order.orderNumber} créée`,
      companyId: req.user.companyId,
      user: req.user.fullName || "Client",
      clientOrSupplierName: client.fullName,
      totalAmount: order.totalPrice,
      quantity: order.products.reduce((sum, p) => sum + p.quantity, 0),
      status: "pending",
      listOfItems: order.products.map((p) => ({
        productName: p.name,
        quantity: p.quantity,
        unitPrice: p.price,
        totalPrice: p.price * p.quantity,
      })),
    });

    const savedOrder = await buildOrderQuery({ _id: order._id });

    return success(res, {
      status: 201,
      data: savedOrder,
    });
  } catch (error) {
    next(error);
  }
};

exports.getAllOrders = async (req, res, next) => {
  try {
    const page = Math.max(toPositiveInteger(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(toPositiveInteger(req.query.limit) || 10, 1), 100);
    const { status, clientId, search } = req.query;
    const query = { companyId: req.user.companyId };

    if (status) {
      query.status = status;
    }

    if (clientId) {
      query.clientId = clientId;
    }

    if (search) {
      const matchingClients = await Client.find({
        companyId: req.user.companyId,
        fullName: { $regex: search, $options: "i" },
      }).select("_id");

      query.$or = [
        { orderNumber: { $regex: search, $options: "i" } },
        { clientId: { $in: matchingClients.map((client) => client._id) } },
      ];
    }

    const [orders, total, stats] = await Promise.all([
      buildOrdersQuery(query)
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip((page - 1) * limit),
      Order.countDocuments(query),
      computeOrderStats(req.user.companyId),
    ]);

    return success(res, {
      data: orders,
      extra: {
        pagination: {
          total,
          page,
          limit,
          pages: Math.max(1, Math.ceil(total / limit)),
        },
        stats,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getMyOrders = async (req, res, next) => {
  try {
    const page = Math.max(toPositiveInteger(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(toPositiveInteger(req.query.limit) || 10, 1), 100);
    const query = { userId: req.user._id };

    if (req.query.status) {
      query.status = req.query.status;
    }

    const [orders, total] = await Promise.all([
      buildOrdersQuery(query)
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip((page - 1) * limit),
      Order.countDocuments(query),
    ]);

    return success(res, {
      data: orders,
      extra: {
        pagination: {
          total,
          page,
          limit,
          pages: Math.max(1, Math.ceil(total / limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getOrderById = async (req, res, next) => {
  try {
    const query = { _id: req.params.id };

    if (req.user.role === "client") {
      query.userId = req.user._id;
    } else {
      query.companyId = req.user.companyId;
    }

    const order = await buildOrderQuery(query);

    if (!order) {
      return failure(res, {
        status: 404,
        message: "Commande non trouvée",
      });
    }

    const timeline = await OrderTimeline.find({ orderId: order._id })
      .populate("userId", "fullName")
      .sort({ timestamp: 1 });

    return success(res, {
      data: {
        order,
        timeline,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { status, note } = req.body;

    if (!ORDER_STATUSES.includes(status)) {
      return failure(res, {
        status: 400,
        message: "Statut de commande invalide",
      });
    }

    const order = await Order.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    });

    if (!order) {
      return failure(res, {
        status: 404,
        message: "Commande non trouvée",
      });
    }

    if (order.status === status) {
      return failure(res, {
        status: 400,
        message: `La commande est déjà ${ORDER_STATUS_LABELS[status]}`,
      });
    }

    const allowedTransitions = ORDER_TRANSITIONS[order.status] || [];

    if (!allowedTransitions.includes(status)) {
      return failure(res, {
        status: 400,
        message: `Transition invalide de ${ORDER_STATUS_LABELS[order.status]} vers ${ORDER_STATUS_LABELS[status]}`,
      });
    }

    // Allocation de stock si on passe à un état actif (non attente, non annulée)
    // et que le stock n'est pas encore alloué
    const isActiveStatus = ["en_preparation", "pret_pour_recuperation", "validee"].includes(status);
    const wasAllocated = order.stockAllocations && order.stockAllocations.length > 0;

    if (isActiveStatus && !wasAllocated) {
      const allocations = [];

      const productIds = order.products.map((product) => product.productId);
      const products = await Product.find({
        _id: { $in: productIds },
        companyId: req.user.companyId,
      });
      const productsById = new Map(products.map((product) => [String(product._id), product]));

      for (const orderedProduct of order.products) {
        const product = productsById.get(String(orderedProduct.productId));
        if (!product) {
          return failure(res, {
            status: 404,
            message: `Produit introuvable : ${orderedProduct.name}`,
          });
        }

        if (availableOrderableStockForProduct(product) < orderedProduct.quantity) {
          return failure(res, {
            status: 400,
            message: `Stock insuffisant pour ${orderedProduct.name}`,
          });
        }
      }

      for (const orderedProduct of order.products) {
        const product = productsById.get(String(orderedProduct.productId));
        const lotAllocations = allocateStock(product, orderedProduct.quantity);
        product.markModified("lots");
        await product.save();
        allocations.push({
          productId: product._id,
          lotAllocations,
        });
      }

      order.stockAllocations = allocations;
    }

    // Restauration de stock si on annule une commande qui avait du stock alloué
    if (status === "annulee" && wasAllocated) {
      for (const allocation of order.stockAllocations || []) {
        const product = await Product.findOne({
          _id: allocation.productId,
          companyId: req.user.companyId,
        });

        if (!product) {
          continue;
        }

        restoreStock(product, allocation.lotAllocations);
        product.markModified("lots");
        await product.save();
      }

      order.stockAllocations = [];
    }

    // Record in Finance if validated
    if (status === "validee") {
      await new Finance({
        dateTime: new Date(),
        type: "sale",
        sourceModule: "Commandes",
        reference: order.orderNumber,
        description: `Commande ${order.orderNumber} récupérée par le client`,
        amount: order.totalPrice,
        isIncome: true,
        paymentMethod: "other", // Default for orders
        employeeName: req.user.fullName,
        orderId: order._id,
        companyId: req.user.companyId,
      }).save();
    }

    const previousStatus = order.status;
    order.status = status;
    await order.save();

    await OrderTimeline.create({
      orderId: order._id,
      status,
      userId: req.user._id,
      note:
        note ||
        `Statut changé de ${ORDER_STATUS_LABELS[previousStatus]} vers ${ORDER_STATUS_LABELS[status]}`,
      companyId: req.user.companyId,
    });

    await logActivity({
      actionType: "update",
      entityType: "order",
      entityId: order._id.toString(),
      entityName: order.orderNumber,
      description: `Commande ${order.orderNumber} mise à jour : ${ORDER_STATUS_LABELS[status]}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
      clientOrSupplierName: order.clientId?.fullName || "Client",
      totalAmount: order.totalPrice,
      quantity: order.products.reduce((sum, p) => sum + p.quantity, 0),
      status: status === "validee" ? "completed" : status === "annulee" ? "cancelled" : "pending",
      listOfItems: order.products.map((p) => ({
        productName: p.name,
        quantity: p.quantity,
        unitPrice: p.price,
        totalPrice: p.price * p.quantity,
      })),
    });

    const updatedOrder = await buildOrderQuery({ _id: order._id });

    return success(res, {
      data: updatedOrder,
    });
  } catch (error) {
    next(error);
  }
};

exports.exportOrders = async (req, res, next) => {
  try {
    const query = { companyId: req.user.companyId };

    if (req.query.status) {
      query.status = req.query.status;
    }

    if (req.query.clientId) {
      query.clientId = req.query.clientId;
    }

    if (req.query.startDate || req.query.endDate) {
      query.createdAt = {};
      if (req.query.startDate) {
        query.createdAt.$gte = new Date(req.query.startDate);
      }
      if (req.query.endDate) {
        query.createdAt.$lte = new Date(req.query.endDate);
      }
    }

    const orders = await buildOrdersQuery(query).sort({ createdAt: -1 });

    let csv = "Numero,Client,Total,Statut,Date\n";
    for (const order of orders) {
      csv += `"${order.orderNumber}","${order.clientId?.fullName || "N/A"}",${order.totalPrice},"${order.status}","${order.createdAt.toISOString()}"\n`;
    }

    res.header("Content-Type", "text/csv");
    res.attachment(`orders_export_${Date.now()}.csv`);
    return res.send(csv);
  } catch (error) {
    next(error);
  }
};
