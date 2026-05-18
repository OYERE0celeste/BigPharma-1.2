const mongoose = require("mongoose");

const OrderProductSchema = new mongoose.Schema(
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
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
    },
    allowSubstitution: {
      type: Boolean,
      default: false,
    },
    substitutedWith: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      default: null,
    },
    substitutedName: {
      type: String,
      default: null,
    },
    originalPrice: {
      type: Number,
      default: null,
    },
  },
  { _id: false }
);

const StockAllocationSchema = new mongoose.Schema(
  {
    lotId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
    },
  },
  { _id: false }
);

const OrderAllocationSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    lotAllocations: {
      type: [StockAllocationSchema],
      default: [],
    },
  },
  { _id: false }
);

const OrderSchema = new mongoose.Schema(
  {
    orderNumber: {
      type: String,
      unique: true,
      required: true,
      trim: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "L'utilisateur est requis"],
    },
    clientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Client",
      required: [true, "Le client est requis"],
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
    products: {
      type: [OrderProductSchema],
      default: [],
      validate: {
        validator: (products) => Array.isArray(products) && products.length > 0,
        message: "La commande doit contenir au moins un article",
      },
    },
    totalPrice: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    status: {
      type: String,
      enum: ["en_attente", "en_preparation", "pret_pour_recuperation", "validee", "annulee"],
      default: "en_attente",
    },

    stockAllocations: {
      type: [OrderAllocationSchema],
      default: [],
    },
    notes: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    pickupMode: {
      type: String,
      enum: ["sur_place", "livraison"],
      default: "sur_place",
    },
    invoiceNumber: {
      type: String,
      unique: true,
      sparse: true,
    },
    invoiceDate: Date,
    collectionCode: {
      type: String,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

OrderSchema.index({ companyId: 1, createdAt: -1 });
OrderSchema.index({ clientId: 1, createdAt: -1 });
OrderSchema.index({ userId: 1, createdAt: -1 });
OrderSchema.index({ status: 1 });

module.exports = mongoose.model("Order", OrderSchema);
