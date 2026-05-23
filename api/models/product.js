const mongoose = require("mongoose");

const LotSchema = new mongoose.Schema({
  lotNumber: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100,
  },
  quantity: {
    type: Number,
    required: true,
    min: 0,
  },
  quantityAvailable: { type: Number, required: true, min: 0 },
  costPrice: { type: Number, required: true, min: 0 },
  manufacturingDate: { type: Date, required: true, default: Date.now },
  expirationDate: { type: Date, required: true },
});

const ProductSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, maxlength: 200 },
    category: { type: String, required: true, trim: true },
    description: { type: String, trim: true, maxlength: 500 },
    barcode: { type: String, trim: true, maxlength: 50, sparse: true },
    qrCode: { type: String, trim: true, maxlength: 500, sparse: true },

    purchasePrice: { type: Number, required: true, min: 0 },
    sellingPrice: { type: Number, required: true, min: 0 },
    lowStockThreshold: { type: Number, required: true, min: 0, default: 10 },
    minStockLevel: { type: Number, required: true, min: 0, default: 10 },
    stockQuantity: { type: Number, required: true, min: 0, default: 0 },
    expirationAlertThreshold: { type: Number, required: true, min: 0, default: 90 }, // seuil d'alerte en jours
    lots: { type: [LotSchema], default: [] },
    substitutes: [{ type: mongoose.Schema.Types.ObjectId, ref: "Product" }],
    isActive: { type: Boolean, default: true },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

ProductSchema.index({ companyId: 1 });

ProductSchema.virtual("totalStock").get(function () {
  return (this.lots || []).reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
});

ProductSchema.virtual("stockStatus").get(function () {
  const available = (this.lots || []).reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
  if (available === 0) return "out_of_stock";
  if (available <= this.lowStockThreshold) return "low_stock";
  return "in_stock";
});

// Virtual pour le statut d'expiration global
ProductSchema.virtual("expirationStatus").get(function () {
  if (!this.lots || this.lots.length === 0) return "OK";

  const now = new Date();
  const thresholdDays = this.expirationAlertThreshold || 90;
  const alertThresholdDate = new Date();
  alertThresholdDate.setDate(now.getDate() + thresholdDays);

  let hasExpired = false;
  let hasNearExpiration = false;

  for (const lot of this.lots) {
    if (new Date(lot.expirationDate) < now) {
      hasExpired = true;
      break;
    }
    if (new Date(lot.expirationDate) <= alertThresholdDate) {
      hasNearExpiration = true;
    }
  }

  if (hasExpired) return "EXPIRÉ";
  if (hasNearExpiration) return "BIENTÔT EXPIRÉ";
  return "OK";
});

ProductSchema.pre("save", async function () {
  // Normalisation
  if (this.name) this.name = this.name.trim();
  if (this.category) this.category = this.category.trim();

  // Toujours recalculer le stock total à partir des lots
  this.stockQuantity = (this.lots || []).reduce(
    (sum, lot) => sum + (lot.quantityAvailable || 0),
    0
  );
});

ProductSchema.index({ name: 1 });
ProductSchema.index({ category: 1 });
ProductSchema.index({ "lots.expirationDate": 1 });

module.exports = mongoose.models.Product || mongoose.model("Product", ProductSchema);
