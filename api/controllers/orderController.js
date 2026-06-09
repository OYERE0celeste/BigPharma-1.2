const Client = require("../models/client");
const Company = require("../models/Company");
const Order = require("../models/order");
const OrderTimeline = require("../models/orderTimeline");
const User = require("../models/User");

const Product = require("../models/product");
const Finance = require("../models/finance");
const { logActivity } = require("../utils/activityLogger");
const { success, failure } = require("../utils/response");
const {
  createInvoiceFromOrder,
  syncInvoiceForOrder,
  toInvoicePayload,
} = require("../utils/invoiceService");
const { createOrderService } = require("../services/orderService");


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

    .populate("products.productId", "name sellingPrice stockQuantity");

const buildOrderQuery = (query = {}) =>
  Order.findOne(query)
    .populate("userId", "fullName email phone")
    .populate("clientId", "fullName email phone address userId")

    .populate("products.productId", "name sellingPrice stockQuantity");

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
    const savedOrder = await createOrderService({
      user: req.user,
      body: req.body,
      io: global.io,
      request: req,
    });

    return success(res, {
      status: 201,
      data: savedOrder,
    });
  } catch (error) {
    return failure(res, { status: 400, message: error.message });
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
    const { updateOrderStatusService } = require("../services/orderService");
    
    const updatedOrder = await updateOrderStatusService({
      orderId: req.params.id,
      companyId: req.user.companyId,
      userId: req.user._id,
      userFullName: req.user.fullName,
      status,
      note
    });

    // Activity log
    const { logActivity } = require("../utils/activityLogger");
    await logActivity({
      actionType: "update",
      entityType: "order",
      entityId: updatedOrder._id.toString(),
      entityName: updatedOrder.orderNumber,
      description: `Commande ${updatedOrder.orderNumber} mise à jour : ${status}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
      clientOrSupplierName: updatedOrder.clientId?.fullName || "Client",
      totalAmount: updatedOrder.totalPrice,
      quantity: updatedOrder.products.reduce((sum, p) => sum + p.quantity, 0),
      status: status === "validee" ? "completed" : status === "annulee" ? "cancelled" : "pending",
      listOfItems: updatedOrder.products.map((p) => ({
        productName: p.name,
        quantity: p.quantity,
        unitPrice: p.price,
        totalPrice: p.price * p.quantity,
      })),
    }, req);

    return success(res, {
      data: updatedOrder,
    });
  } catch (error) {
    if (error.message === "Commande non trouvée") {
      return failure(res, { status: 404, message: error.message });
    }
    return failure(res, { status: 400, message: error.message });
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

exports.getOrderInvoice = async (req, res, next) => {
  try {
    const order = await buildOrderQuery({ _id: req.params.id });

    if (!order) {
      return failure(res, {
        status: 404,
        message: "Commande introuvable",
      });
    }

    const orderUserIdStr = order.userId && order.userId._id ? order.userId._id.toString() : order.userId.toString();
    if (req.user.role === "client" && orderUserIdStr !== req.user._id.toString()) {
      return failure(res, {
        status: 403,
        message: "Accès refusé",
      });
    }

    const invoice = await syncInvoiceForOrder(order);
    if (!invoice) {
      return failure(res, {
        status: 404,
        message: "La facture n'est pas encore disponible pour cette commande",
      });
    }

    return success(res, { data: toInvoicePayload(invoice) });
  } catch (error) {
    next(error);
  }
};

exports.substituteOrderItem = async (req, res, next) => {
  try {
    const { itemIndex, substituteProductId } = req.body;
    const order = await Order.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    });

    if (!order) {
      return failure(res, { status: 404, message: "Commande non trouvée" });
    }

    if (!["en_attente", "en_preparation"].includes(order.status)) {
      return failure(res, {
        status: 400,
        message: "La substitution n'est possible qu'avant la préparation finale",
      });
    }

    const item = order.products[itemIndex];
    if (!item) {
      return failure(res, { status: 400, message: "Article introuvable dans la commande" });
    }

    if (!item.allowSubstitution) {
      return failure(res, {
        status: 400,
        message: "Le client n'a pas autorisé la substitution pour cet article",
      });
    }

    const substituteProduct = await Product.findOne({
      _id: substituteProductId,
      companyId: req.user.companyId,
      isActive: true,
    });

    if (!substituteProduct) {
      return failure(res, { status: 404, message: "Produit de substitution introuvable" });
    }

    const availableStock = availableOrderableStockForProduct(substituteProduct);
    if (availableStock < item.quantity) {
      return failure(res, {
        status: 400,
        message: `Stock insuffisant pour le substitut ${substituteProduct.name} (${availableStock} dispo)`,
      });
    }

    // Track original values
    item.originalPrice = item.price;
    item.substitutedWith = substituteProduct._id;
    item.substitutedName = substituteProduct.name;

    // Update to substitute
    item.productId = substituteProduct._id;
    item.name = substituteProduct.name;
    item.price = substituteProduct.sellingPrice;

    // Recalculate total
    order.totalPrice = order.products.reduce((sum, p) => sum + p.price * p.quantity, 0);
    order.markModified("products");
    await order.save();

    await OrderTimeline.create({
      orderId: order._id,
      status: order.status,
      userId: req.user._id,
      note: `Substitution : ${item.substitutedName} remplace l'article original (prix original: ${item.originalPrice} FCFA -> nouveau prix: ${item.price} FCFA)`,
      companyId: req.user.companyId,
    });

    await logActivity({
      actionType: "update",
      entityType: "order",
      entityId: order._id.toString(),
      entityName: order.orderNumber,
      description: `Substitution dans commande ${order.orderNumber}: ${item.substitutedName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
      totalAmount: order.totalPrice,
      status: "pending",
    }, req);

    const updatedOrder = await buildOrderQuery({ _id: order._id });

    if (global.io) {
      global.io.to(req.user.companyId.toString()).emit("order-status-update", updatedOrder);
    }

    return success(res, { data: updatedOrder });
  } catch (error) {
    next(error);
  }
};

exports.getProductSubstitutes = async (req, res, next) => {
  try {
    const product = await Product.findOne({
      _id: req.params.productId,
      companyId: req.user.companyId,
    }).populate("substitutes", "name sellingPrice stockQuantity category lots isActive");

    if (!product) {
      return failure(res, { status: 404, message: "Produit introuvable" });
    }

    const substitutes = (product.substitutes || [])
      .filter((s) => s.isActive)
      .map((s) => ({
        _id: s._id,
        name: s.name,
        sellingPrice: s.sellingPrice,
        category: s.category,
        availableStock: availableOrderableStockForProduct(s),
      }));

    return success(res, { data: substitutes });
  } catch (error) {
    next(error);
  }
};
