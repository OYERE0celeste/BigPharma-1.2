const express = require("express");
const router = express.Router();
const Order = require("../models/order");
const OrderTimeline = require("../models/orderTimeline");
const Product = require("../models/product");
const roleMiddleware = require("../middleware/roleMiddleware");
const { logActivity } = require("../utils/activityLogger");

// Helper to generate Order Number: CMD-YYYY-XXXX
const generateOrderNumber = async () => {
  const year = new Date().getFullYear();
  const startOfYear = new Date(year, 0, 1);
  const endOfYear = new Date(year, 11, 31, 23, 59, 59);

  const count = await Order.countDocuments({
    createdAt: { $gte: startOfYear, $lte: endOfYear }
  });

  const sequence = (count + 1).toString().padStart(4, "0");
  return `CMD-${year}-${sequence}`;
};

// @route   POST /api/orders
// @desc    Create a new order
// @access  Admin, Pharmacien, Assistant
router.post("/", roleMiddleware(["admin", "pharmacien", "assistant"]), async (req, res, next) => {
  try {
    const { client, items, notes } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: "La commande doit contenir au moins un article" });
    }

    let calculatedTotal = 0;
    const processedItems = [];

    // Validation des produits et calcul du total
    for (const item of items) {
      const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId });
      if (!product) {
        return res.status(404).json({ success: false, message: `Produit non trouvé : ${item.product}` });
      }

      const subtotal = product.sellingPrice * item.quantity;
      calculatedTotal += subtotal;

      processedItems.push({
        product: product._id,
        name: product.name,
        price: product.sellingPrice,
        quantity: item.quantity,
        subtotal: subtotal
      });
    }

    const orderNumber = await generateOrderNumber();

    const order = new Order({
      orderNumber,
      client,
      items: processedItems,
      total: calculatedTotal,
      createdBy: req.user._id,
      companyId: req.user.companyId,
      notes,
      status: "pending"
    });

    const savedOrder = await order.save();

    // Créer l'entrée dans la timeline
    const timelineEntry = new OrderTimeline({
      orderId: savedOrder._id,
      status: "pending",
      userId: req.user._id,
      note: "Commande créée",
      companyId: req.user.companyId
    });
    await timelineEntry.save();

    await logActivity({
      actionType: "create",
      entityType: "order",
      entityId: savedOrder._id,
      entityName: orderNumber,
      description: `Nouvelle commande créée par ${req.user.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName
    });

    res.status(201).json({ success: true, data: savedOrder });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/orders
// @desc    Get all orders with filters and pagination
// @access  Admin, Pharmacien, Assistant, Caissier
router.get("/", roleMiddleware(["admin", "pharmacien", "assistant", "caissier"]), async (req, res, next) => {
  try {
    const { page = 1, limit = 10, status, clientId, search } = req.query;
    const query = { companyId: req.user.companyId };

    if (status) query.status = status;
    if (clientId) query.client = clientId;
    if (search) {
      query.orderNumber = { $regex: search, $options: "i" };
    }

    const orders = await Order.find(query)
      .populate("client", "fullName phone")
      .populate("createdBy", "fullName")
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Order.countDocuments(query);

    res.json({
      success: true,
      data: orders,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/orders/:id
// @desc    Update order details (if pending)
// @access  Admin, Pharmacien
router.put("/:id", roleMiddleware(["admin", "pharmacien"]), async (req, res, next) => {
  try {
    const { client, items, notes } = req.body;
    const order = await Order.findOne({ _id: req.params.id, companyId: req.user.companyId });

    if (!order) {
      return res.status(404).json({ success: false, message: "Commande non trouvée" });
    }

    if (order.status !== "pending") {
      return res.status(400).json({ success: false, message: "Seules les commandes en attente peuvent être modifiées" });
    }

    if (client) order.client = client;
    if (notes !== undefined) order.notes = notes;

    if (items && items.length > 0) {
      let calculatedTotal = 0;
      const processedItems = [];

      for (const item of items) {
        const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId });
        if (!product) {
          return res.status(404).json({ success: false, message: `Produit non trouvé : ${item.product}` });
        }

        const subtotal = product.sellingPrice * item.quantity;
        calculatedTotal += subtotal;

        processedItems.push({
          product: product._id,
          name: product.name,
          price: product.sellingPrice,
          quantity: item.quantity,
          subtotal: subtotal
        });
      }
      order.items = processedItems;
      order.total = calculatedTotal;
    }

    const savedOrder = await order.save();

    const timelineEntry = new OrderTimeline({
      orderId: savedOrder._id,
      status: order.status,
      userId: req.user._id,
      note: "Commande modifiée",
      companyId: req.user.companyId
    });
    await timelineEntry.save();

    res.json({ success: true, data: savedOrder });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/orders/export
// @desc    Export orders to CSV
// @access  Admin, Pharmacien
router.get("/export", roleMiddleware(["admin", "pharmacien"]), async (req, res, next) => {
  try {
    const { status, clientId, startDate, endDate } = req.query;
    const query = { companyId: req.user.companyId };

    if (status) query.status = status;
    if (clientId) query.client = clientId;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const orders = await Order.find(query)
      .populate("client", "fullName")
      .sort({ createdAt: -1 });

    let csv = "Order Number,Client,Total,Status,Date\n";
    orders.forEach(order => {
      csv += `${order.orderNumber},${order.client?.fullName || "N/A"},${order.total},${order.status},${order.createdAt.toISOString()}\n`;
    });

    res.header("Content-Type", "text/csv");
    res.attachment(`orders_export_${Date.now()}.csv`);
    return res.send(csv);
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/orders/:id
// @desc    Get order details + timeline
// @access  Admin, Pharmacien, Assistant, Caissier
router.get("/:id", roleMiddleware(["admin", "pharmacien", "assistant", "caissier"]), async (req, res, next) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, companyId: req.user.companyId })
      .populate("client")
      .populate("createdBy", "fullName")
      .populate("items.product");

    if (!order) {
      return res.status(404).json({ success: false, message: "Commande non trouvée" });
    }

    const timeline = await OrderTimeline.find({ orderId: order._id })
      .populate("userId", "fullName")
      .sort({ timestamp: 1 });

    res.json({ success: true, data: { order, timeline } });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/orders/:id/status
// @desc    Update order status
// @access  Admin, Pharmacien
router.patch("/:id/status", roleMiddleware(["admin", "pharmacien"]), async (req, res, next) => {
  try {
    const { status, note } = req.body;
    const order = await Order.findOne({ _id: req.params.id, companyId: req.user.companyId });

    if (!order) {
      return res.status(404).json({ success: false, message: "Commande non trouvée" });
    }

    // Protection: Ne pas revenir en arrière ou vers le même statut inutilement (optionnel)
    if (order.status === status) {
      return res.status(400).json({ success: false, message: `La commande est déjà au statut : ${status}` });
    }

    const oldStatus = order.status;
    order.status = status;

    // Gestion du stock si le statut passe à "validated"
    if (status === "validated" && oldStatus === "pending") {
      for (const item of order.items) {
        const product = await Product.findOne({ _id: item.product, companyId: req.user.companyId });
        if (!product) continue;

        // On déduit du stock total (ou d'un lot spécifique si on l'avait choisi, mais ici on reste simple)
        // Note: Le projet semble utiliser des lots. On va essayer de déduire du premier lot disponible avec assez de stock.
        let remainingToDeduct = item.quantity;
        for (const lot of product.lots) {
          if (lot.quantityAvailable >= remainingToDeduct) {
            lot.quantityAvailable -= remainingToDeduct;
            remainingToDeduct = 0;
            break;
          } else {
            remainingToDeduct -= lot.quantityAvailable;
            lot.quantityAvailable = 0;
          }
        }

        if (remainingToDeduct > 0) {
          return res.status(400).json({ 
            success: false, 
            message: `Stock insuffisant pour ${product.name}. Manquant: ${remainingToDeduct}` 
          });
        }

        product.stockQuantity = product.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
        await product.save();
      }
    }

    await order.save();

    // Ajouter à la timeline
    const timelineEntry = new OrderTimeline({
      orderId: order._id,
      status: status,
      userId: req.user._id,
      note: note || `Statut changé de ${oldStatus} à ${status}`,
      companyId: req.user.companyId
    });
    await timelineEntry.save();

    await logActivity({
      actionType: "update",
      entityType: "order",
      entityId: order._id,
      entityName: order.orderNumber,
      description: `Statut de la commande ${order.orderNumber} changé en ${status}`,
      companyId: req.user.companyId,
      user: req.user.fullName
    });

    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/orders/:id
// @desc    Cancel order (Admin only)
// @access  Admin
router.delete("/:id", roleMiddleware(["admin"]), async (req, res, next) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, companyId: req.user.companyId });

    if (!order) {
      return res.status(404).json({ success: false, message: "Commande non trouvée" });
    }

    if (order.status === "cancelled") {
      return res.status(400).json({ success: false, message: "La commande est déjà annulée" });
    }

    order.status = "cancelled";
    await order.save();

    const timelineEntry = new OrderTimeline({
      orderId: order._id,
      status: "cancelled",
      userId: req.user._id,
      note: "Commande annulée",
      companyId: req.user.companyId
    });
    await timelineEntry.save();

    res.json({ success: true, message: "Commande annulée avec succès" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
