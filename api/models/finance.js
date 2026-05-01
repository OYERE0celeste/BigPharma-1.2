const mongoose = require("mongoose");

const FinanceSchema = new mongoose.Schema(
  {
    dateTime: {
      type: Date,
      required: true,
      default: Date.now,
    },
    type: {
      type: String,
      required: true,
      trim: true,
      enum: ["sale", "purchase", "manual", "refund", "other", "vente", "achat", "remboursement"],
      default: "other",
    },
    sourceModule: {
      type: String,
      required: true,
      trim: true,
      enum: [
        "Ventes",
        "Commandes",
        "Manual",
        "Sales",
        "Orders",
        "Manual Entry",
        "ventes",
        "commandes",
      ],
      default: "Manual",
    },
    reference: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
      default: "",
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    isIncome: {
      type: Boolean,
      required: true,
    },
    paymentMethod: {
      type: String,
      required: true,
      trim: true,
      enum: ["cash", "card", "transfer", "insurance", "other", "Virement", "Espèces", "Carte"],
      default: "other",
    },
    employeeName: {
      type: String,
      trim: true,
      default: "",
    },
    saleId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Sale",
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
    },
    supplierOrderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Supplier",
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
  },
  {
    timestamps: true,
  }
);

FinanceSchema.index({ companyId: 1, dateTime: -1 });
FinanceSchema.index({ type: 1 });
FinanceSchema.index({ sourceModule: 1 });

module.exports = mongoose.model("Finance", FinanceSchema);
