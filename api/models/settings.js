const mongoose = require("mongoose");

const SettingsSchema = new mongoose.Schema(
  {
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: true,
      unique: true,
    },
    currency: {
      type: String,
      default: "FCFA",
    },
    taxRate: {
      type: Number,
      default: 18, // 18% VAT
    },
    defaultMargin: {
      type: Number,
      default: 25, // 25% default margin
    },
    lowStockThreshold: {
      type: Number,
      default: 10,
    },
    enableStockAutoDeduction: {
      type: Boolean,
      default: true,
    },
    invoiceFooter: {
      type: String,
      default: "Merci de votre confiance. Prenez soin de vous !",
    },
    businessHours: {
      monday: { open: String, close: String, closed: Boolean },
      tuesday: { open: String, close: String, closed: Boolean },
      wednesday: { open: String, close: String, closed: Boolean },
      thursday: { open: String, close: String, closed: Boolean },
      friday: { open: String, close: String, closed: Boolean },
      saturday: { open: String, close: String, closed: Boolean },
      sunday: { open: String, close: String, closed: Boolean },
    }
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Settings", SettingsSchema);
