const Order = require("../models/order");
const OrderTimeline = require("../models/orderTimeline");
const User = require("../models/User");
const Client = require("../models/client");
const Company = require("../models/Company");
const { success, failure } = require("../utils/response");
const { logActivity } = require("../utils/activityLogger");
const {
  sendPrescriptionValidatedEmail,
  sendPrescriptionRejectedEmail,
} = require("../utils/mailService");

// ─── Helpers ────────────────────────────────────────────────────────────────

const prescriptionProjection = "-prescription.data";

const buildOrderQuery = (req, extra = {}) => ({
  companyId: req.user.companyId,
  "prescription.data": { $exists: true },
  ...extra,
});

// ─── GET /orders/prescriptions  (pharmacie) ────────────────────────────────
// Liste toutes les commandes ayant une ordonnance, filtrables par statut
exports.listPrescriptions = async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const query = buildOrderQuery(req);
    if (status && ["pending", "validated", "rejected"].includes(status)) {
      query["prescription.status"] = status;
    }

    const [orders, total] = await Promise.all([
      Order.find(query)
        .select(prescriptionProjection)
        .populate("clientId", "fullName phone email")
        .populate("userId", "fullName email")
        .populate("prescription.validatedBy", "fullName")
        .sort({ "prescription.uploadedAt": -1 })
        .skip(skip)
        .limit(Number(limit))
        .lean(),
      Order.countDocuments(query),
    ]);

    // Stats rapides
    const [pendingCount, validatedCount, rejectedCount] = await Promise.all([
      Order.countDocuments({ ...buildOrderQuery(req), "prescription.status": "pending" }),
      Order.countDocuments({ ...buildOrderQuery(req), "prescription.status": "validated" }),
      Order.countDocuments({ ...buildOrderQuery(req), "prescription.status": "rejected" }),
    ]);

    return success(res, {
      data: orders,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
      stats: { pending: pendingCount, validated: validatedCount, rejected: rejectedCount },
    });
  } catch (error) {
    next(error);
  }
};

// ─── PATCH /orders/:id/prescription/validate  (pharmacie) ─────────────────
exports.validatePrescription = async (req, res, next) => {
  try {
    const { pharmacistNotes } = req.body;

    const order = await Order.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
      "prescription.data": { $exists: true },
    }).populate("clientId", "fullName email").populate("userId", "fullName email");

    if (!order) {
      return failure(res, { status: 404, message: "Commande ou ordonnance introuvable" });
    }

    if (!order.prescription) {
      return failure(res, { status: 400, message: "Aucune ordonnance jointe à cette commande" });
    }

    if (order.prescription.status === "validated") {
      return failure(res, { status: 400, message: "Cette ordonnance est déjà validée" });
    }

    order.prescription.status = "validated";
    order.prescription.validatedBy = req.user._id;
    order.prescription.validatedAt = new Date();
    order.prescription.rejectionReason = null;
    if (pharmacistNotes) order.prescription.pharmacistNotes = pharmacistNotes;

    await order.save();

    await OrderTimeline.create({
      orderId: order._id,
      status: order.status,
      userId: req.user._id,
      note: `Ordonnance validée par ${req.user.fullName || "le pharmacien"}${pharmacistNotes ? ` — Notes : ${pharmacistNotes}` : ""}`,
      companyId: order.companyId,
    });

    await logActivity({
      userId: req.user._id,
      companyId: req.user.companyId,
      action: "validate_prescription",
      target: "Order",
      targetId: order._id,
      details: { orderNumber: order.orderNumber },
    });

    // Notification email au client
    const clientEmail = order.userId?.email || order.clientId?.email;
    const clientName = order.userId?.fullName || order.clientId?.fullName || "Client";
    if (clientEmail) {
      const company = await Company.findById(order.companyId).select("name").lean();
      sendPrescriptionValidatedEmail({
        email: clientEmail,
        fullName: clientName,
        orderNumber: order.orderNumber,
        pharmacistNotes: pharmacistNotes || null,
        companyName: company?.name || "BigPharma",
      }).catch(() => {});
    }

    return success(res, { data: order, message: "Ordonnance validée avec succès" });
  } catch (error) {
    next(error);
  }
};

// ─── PATCH /orders/:id/prescription/reject  (pharmacie) ───────────────────
exports.rejectPrescription = async (req, res, next) => {
  try {
    const { rejectionReason } = req.body;

    if (!rejectionReason || !rejectionReason.trim()) {
      return failure(res, { status: 400, message: "Un motif de refus est obligatoire" });
    }

    const order = await Order.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
      "prescription.data": { $exists: true },
    }).populate("clientId", "fullName email").populate("userId", "fullName email");

    if (!order) {
      return failure(res, { status: 404, message: "Commande ou ordonnance introuvable" });
    }

    if (!order.prescription) {
      return failure(res, { status: 400, message: "Aucune ordonnance jointe à cette commande" });
    }

    if (order.prescription.status === "rejected") {
      return failure(res, { status: 400, message: "Cette ordonnance est déjà rejetée" });
    }

    order.prescription.status = "rejected";
    order.prescription.validatedBy = req.user._id;
    order.prescription.validatedAt = new Date();
    order.prescription.rejectionReason = rejectionReason.trim();

    await order.save();

    await OrderTimeline.create({
      orderId: order._id,
      status: order.status,
      userId: req.user._id,
      note: `Ordonnance refusée — Motif : ${rejectionReason.trim()}`,
      companyId: order.companyId,
    });

    await logActivity({
      userId: req.user._id,
      companyId: req.user.companyId,
      action: "reject_prescription",
      target: "Order",
      targetId: order._id,
      details: { orderNumber: order.orderNumber, reason: rejectionReason },
    });

    // Notification email au client
    const clientEmail = order.userId?.email || order.clientId?.email;
    const clientName = order.userId?.fullName || order.clientId?.fullName || "Client";
    if (clientEmail) {
      const company = await Company.findById(order.companyId).select("name").lean();
      sendPrescriptionRejectedEmail({
        email: clientEmail,
        fullName: clientName,
        orderNumber: order.orderNumber,
        rejectionReason: rejectionReason.trim(),
        companyName: company?.name || "BigPharma",
      }).catch(() => {});
    }

    return success(res, { data: order, message: "Ordonnance refusée" });
  } catch (error) {
    next(error);
  }
};

// ─── GET /orders/my/prescriptions  (client) ────────────────────────────────
exports.getMyPrescriptions = async (req, res, next) => {
  try {
    const orders = await Order.find({
      userId: req.user._id,
      "prescription.data": { $exists: true },
    })
      .select("-prescription.data")
      .sort({ "prescription.uploadedAt": -1 })
      .lean();

    return success(res, { data: orders });
  } catch (error) {
    next(error);
  }
};
