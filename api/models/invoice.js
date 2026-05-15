const mongoose = require("mongoose");

const InvoicePartySchema = new mongoose.Schema(
  {
    fullName: { type: String, trim: true },
    name: { type: String, trim: true },
    email: { type: String, trim: true, lowercase: true },
    phone: { type: String, trim: true },
    address: { type: String, trim: true },
    city: { type: String, trim: true },
    country: { type: String, trim: true },
  },
  { _id: false }
);

const InvoiceItemSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
    },
    unitPrice: {
      type: Number,
      required: true,
      min: 0,
    },
    totalPrice: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  { _id: false }
);

const InvoiceSchema = new mongoose.Schema(
  {
    invoiceNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
      unique: true,
    },
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
    orderNumber: {
      type: String,
      required: true,
      trim: true,
    },
    invoiceDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
    pickupMode: {
      type: String,
      enum: ["sur_place", "livraison"],
      default: "sur_place",
    },
    paymentStatus: {
      type: String,
      enum: ["en_attente", "payee", "annulee"],
      default: "en_attente",
    },
    orderStatus: {
      type: String,
      enum: ["en_attente", "en_preparation", "pret_pour_recuperation", "validee", "annulee"],
      required: true,
    },
    collectionCode: {
      type: String,
      trim: true,
    },
    clientSnapshot: {
      type: InvoicePartySchema,
      default: {},
    },
    pharmacySnapshot: {
      type: InvoicePartySchema,
      default: {},
    },
    items: {
      type: [InvoiceItemSchema],
      default: [],
    },
    subtotal: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    totalAmount: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    currency: {
      type: String,
      default: "FCFA",
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

InvoiceSchema.index({ companyId: 1, invoiceDate: -1 });
InvoiceSchema.index({ userId: 1, invoiceDate: -1 });
InvoiceSchema.index({ clientId: 1, invoiceDate: -1 });
InvoiceSchema.index({ paymentStatus: 1, orderStatus: 1 });

module.exports = mongoose.models.Invoice || mongoose.model("Invoice", InvoiceSchema);
