const Client = require("../models/client");
const Complaint = require("../models/complaint");
const Invoice = require("../models/invoice");
const Order = require("../models/order");
const Product = require("../models/product");
const User = require("../models/User");
const { sendNotification, notifyStaff } = require("../utils/notificationHelper");
const { success, failure } = require("../utils/response");
const { sendComplaintStatusEmail } = require("../utils/mailService");

const COMPLAINT_STATUSES = ["en_attente", "en_cours", "resolue", "rejetee"];

const CATEGORY_LABELS = {
  produit_endommage: "Produit endommage",
  mauvaise_commande: "Mauvaise commande recue",
  retard_livraison: "Retard de livraison",
  produit_manquant: "Produit manquant",
  erreur_facture: "Erreur sur la facture",
  probleme_utilisation: "Probleme lie a l'utilisation",
  autre: "Autre reclamation",
};

async function resolveClient(req) {
  return Client.findOne({ userId: req.user._id, companyId: req.user.companyId });
}

async function generateComplaintNumber(companyId) {
  const year = new Date().getFullYear();
  const start = new Date(year, 0, 1);
  const end = new Date(year, 11, 31, 23, 59, 59, 999);
  const count = await Complaint.countDocuments({
    companyId,
    createdAt: { $gte: start, $lte: end },
  });
  return `REC-${year}-${String(count + 1).padStart(5, "0")}`;
}

exports.getMyComplaints = async (req, res, next) => {
  try {
    const query = req.user.role === "client"
      ? { userId: req.user._id }
      : { companyId: req.user.companyId };

    if (req.query.status) {
      query.status = req.query.status;
    }
    if (req.query.category) {
      query.category = req.query.category;
    }
    if (req.query.search) {
      query.$or = [
        { complaintNumber: { $regex: req.query.search, $options: "i" } },
        { subject: { $regex: req.query.search, $options: "i" } },
        { "clientSnapshot.fullName": { $regex: req.query.search, $options: "i" } },
      ];
    }

    const complaints = await Complaint.find(query).sort({ createdAt: -1 }).limit(200);
    return success(res, { data: complaints });
  } catch (error) {
    next(error);
  }
};

exports.getComplaintById = async (req, res, next) => {
  try {
    const query = req.user.role === "client"
      ? { _id: req.params.id, userId: req.user._id }
      : { _id: req.params.id, companyId: req.user.companyId };

    const complaint = await Complaint.findOne(query);
    if (!complaint) {
      return failure(res, { status: 404, message: "Reclamation introuvable" });
    }

    return success(res, { data: complaint });
  } catch (error) {
    next(error);
  }
};

exports.createComplaint = async (req, res, next) => {
  try {
    if (req.user.role !== "client") {
      return failure(res, { status: 403, message: "Seuls les clients peuvent soumettre une reclamation" });
    }

    const { category, subject, description, orderId, invoiceId, productId } = req.body;

    if (!category || !CATEGORY_LABELS[category]) {
      return failure(res, { status: 400, message: "Categorie de reclamation invalide" });
    }
    if (!description || !description.trim()) {
      return failure(res, { status: 400, message: "Description requise" });
    }

    const client = await resolveClient(req);
    if (!client) {
      return failure(res, { status: 404, message: "Profil client introuvable" });
    }

    let order = null;
    let invoice = null;
    let product = null;

    if (orderId) {
      order = await Order.findOne({
        _id: orderId,
        userId: req.user._id,
        companyId: req.user.companyId,
      });
      if (!order) {
        return failure(res, { status: 404, message: "Commande associee introuvable" });
      }
    }

    if (invoiceId) {
      invoice = await Invoice.findOne({
        _id: invoiceId,
        userId: req.user._id,
        companyId: req.user.companyId,
      });
      if (!invoice) {
        return failure(res, { status: 404, message: "Facture associee introuvable" });
      }
    }

    if (productId) {
      product = await Product.findById(productId);
      if (!product) {
        return failure(res, { status: 404, message: "Produit associe introuvable" });
      }
    }

    const complaint = await Complaint.create({
      userId: req.user._id,
      clientId: client._id,
      companyId: req.user.companyId,
      orderId: order?._id,
      invoiceId: invoice?._id,
      productId: product?._id,
      complaintNumber: await generateComplaintNumber(req.user.companyId),
      category,
      subject: subject?.trim() || CATEGORY_LABELS[category],
      description: description.trim(),
      status: "en_attente",
      clientSnapshot: {
        fullName: client.fullName,
        email: client.email || req.user.email || "",
        phone: client.phone || "",
      },
      orderSnapshot: {
        orderNumber: order?.orderNumber || invoice?.orderNumber || "",
        invoiceNumber: invoice?.invoiceNumber || order?.invoiceNumber || "",
        totalAmount: order?.totalPrice || invoice?.totalAmount || 0,
        pickupMode: order?.pickupMode || invoice?.pickupMode || "sur_place",
      },
      productSnapshot: {
        name: product?.name || "",
      },
      history: [
        {
          status: "en_attente",
          note: "Reclamation soumise par le client",
          actorId: req.user._id,
          actorName: req.user.fullName || client.fullName,
        },
      ],
    });

    await notifyStaff({
      companyId: req.user.companyId,
      title: "Nouvelle reclamation client",
      message: `${client.fullName} a signale: ${complaint.subject}.`,
      type: "complaint",
      data: { complaintId: complaint._id, orderId: complaint.orderId, invoiceId: complaint.invoiceId },
    });

    return success(res, { status: 201, data: complaint });
  } catch (error) {
    next(error);
  }
};

exports.updateComplaintStatus = async (req, res, next) => {
  try {
    const { status, note } = req.body;
    if (!COMPLAINT_STATUSES.includes(status)) {
      return failure(res, { status: 400, message: "Statut de reclamation invalide" });
    }

    const complaint = await Complaint.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    });
    if (!complaint) {
      return failure(res, { status: 404, message: "Reclamation introuvable" });
    }

    complaint.status = status;
    if (note) {
      complaint.resolutionNote = note.trim();
    }
    complaint.history.push({
      status,
      note: note?.trim() || `Statut mis a jour vers ${status}`,
      actorId: req.user._id,
      actorName: req.user.fullName,
      createdAt: new Date(),
    });
    await complaint.save();

    await sendNotification({
      userId: complaint.userId,
      companyId: complaint.companyId,
      title: "Mise a jour de votre reclamation",
      message: `Votre reclamation ${complaint.complaintNumber} est maintenant ${status}.`,
      type: "complaint",
      data: { complaintId: complaint._id, status },
    });

    const complaintUser = await User.findById(complaint.userId).select("email fullName").lean();
    if (complaintUser) {
      await sendComplaintStatusEmail({
        email: complaintUser.email,
        fullName: complaintUser.fullName,
        complaintNumber: complaint.complaintNumber,
        status,
        companyName: "BigPharma",
      });
    }

    return success(res, { data: complaint });
  } catch (error) {
    next(error);
  }
};
