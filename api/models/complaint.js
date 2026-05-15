const mongoose = require("mongoose");

const ComplaintHistorySchema = new mongoose.Schema(
  {
    status: {
      type: String,
      enum: ["en_attente", "en_cours", "resolue", "rejetee"],
      required: true,
    },
    note: {
      type: String,
      trim: true,
      maxlength: 1000,
      default: "",
    },
    actorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    actorName: {
      type: String,
      trim: true,
      required: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false }
);

const ComplaintSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    clientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Client",
      required: true,
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: true,
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
    },
    invoiceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Invoice",
    },
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
    },
    complaintNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    category: {
      type: String,
      enum: [
        "produit_endommage",
        "mauvaise_commande",
        "retard_livraison",
        "produit_manquant",
        "erreur_facture",
        "probleme_utilisation",
        "autre",
      ],
      required: true,
    },
    subject: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      maxlength: 2000,
    },
    status: {
      type: String,
      enum: ["en_attente", "en_cours", "resolue", "rejetee"],
      default: "en_attente",
    },
    resolutionNote: {
      type: String,
      trim: true,
      maxlength: 1000,
      default: "",
    },
    clientSnapshot: {
      fullName: { type: String, trim: true },
      email: { type: String, trim: true, lowercase: true },
      phone: { type: String, trim: true },
    },
    orderSnapshot: {
      orderNumber: { type: String, trim: true },
      invoiceNumber: { type: String, trim: true },
      totalAmount: { type: Number, min: 0, default: 0 },
      pickupMode: {
        type: String,
        enum: ["sur_place", "livraison"],
      },
    },
    productSnapshot: {
      name: { type: String, trim: true },
    },
    history: {
      type: [ComplaintHistorySchema],
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

ComplaintSchema.index({ companyId: 1, createdAt: -1 });
ComplaintSchema.index({ userId: 1, createdAt: -1 });
ComplaintSchema.index({ clientId: 1, createdAt: -1 });
ComplaintSchema.index({ status: 1, category: 1 });

module.exports = mongoose.models.Complaint || mongoose.model("Complaint", ComplaintSchema);
