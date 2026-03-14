const mongoose = require("mongoose");

const SaleItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  unitPrice: {
    type: Number,
    required: true,
    min: 0
  },
  total: {
    type: Number,
    required: true,
    min: 0
  }
});

const SaleSchema = new mongoose.Schema({
  client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: true
  },
  items: [SaleItemSchema],
  subtotal: {
    type: Number,
    required: true,
    min: 0
  },
  tax: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  total: {
    type: Number,
    required: true,
    min: 0
  },
  paymentMethod: {
    type: String,
    enum: ["cash", "card", "mobile_money", "transfer"],
    required: true
  },
  paymentStatus: {
    type: String,
    enum: ["pending", "paid", "refunded"],
    default: "paid"
  },
  status: {
    type: String,
    enum: ["active", "cancelled", "refunded"],
    default: "active"
  },
  discount: {
    type: Number,
    min: 0,
    default: 0
  },
  notes: {
    type: String,
    trim: true,
    maxlength: 500
  },
  saleDate: {
    type: Date,
    required: true,
    default: Date.now
  }
}, {
  timestamps: true,
});

// Index for efficient queries
SaleSchema.index({ client: 1 });
SaleSchema.index({ saleDate: -1 });
SaleSchema.index({ status: 1 });
SaleSchema.index({ paymentStatus: 1 });

module.exports = mongoose.model("Sale", SaleSchema);
