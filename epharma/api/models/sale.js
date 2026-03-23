const mongoose = require("mongoose");

const SaleItemSchema = new mongoose.Schema({
  product: {
    type: String,
    ref: 'Product',
    required: true
  },
  lotNumber: {
    type: String,
    required: true, // indispensable en pharmacie pour la traçabilité
    trim: true
  },
  expirationDate: {
    type: Date,
    required: true // vérifier que le produit vendu n’est pas périmé
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
    type: String,
    ref: 'Client',
    required: true
  },
  invoiceNumber: {
    type: String,
    trim: true,
    default: function() {
      return `INV-${Date.now()}`;
    }
  },
  pharmacist: {
    type: String,
    required: true,
    trim: true
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
  discount: {
    type: Number,
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
    enum: ["cash", "card", "mobile_money", "insurance"], // enum pour éviter incohérences
    required: true
  },
  paymentStatus: {
    type: String,
    enum: ["paid", "pending", "cancelled"],
    default: "paid"
  },
  status: {
    type: String,
    enum: ["active", "cancelled"],
    default: "active"
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
  },
  companyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Company",
    required: [true, "La société est requise"],
  },
}, {
  timestamps: true,
});

SaleSchema.index({ companyId: 1 });

// Index pour requêtes fréquentes
SaleSchema.index({ client: 1 });
SaleSchema.index({ pharmacist: 1 });
SaleSchema.index({ saleDate: -1 });
SaleSchema.index({ status: 1 });
SaleSchema.index({ paymentStatus: 1 });

module.exports = mongoose.model("Sale", SaleSchema);
