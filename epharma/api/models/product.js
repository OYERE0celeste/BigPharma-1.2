const mongoose = require("mongoose");

const LotSchema = new mongoose.Schema({
  lotNumber: { type: String, required: true, trim: true, maxlength: 100 },
  quantity: { type: Number, required: true, min: 0 },
  quantityAvailable: { type: Number, required: true, min: 0 },
  costPrice: { type: Number, required: true, min: 0 },
  expirationDate: { type: Date, required: true },
});

const ProductSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true, maxlength: 200 },
  category: { type: String, required: true, trim: true },
  description: { type: String, trim: true, maxlength: 500 },
  supplier: { type: String, trim: true, maxlength: 200 },
  barcode: { type: String, trim: true, maxlength: 50 },
  prescriptionRequired: { type: Boolean, default: false },
  purchasePrice: { type: Number, required: true, min: 0 },
  sellingPrice: { type: Number, required: true, min: 0 },
  lowStockThreshold: { type: Number, required: true, min: 0, default: 10 },
  minStockLevel: { type: Number, required: true, min: 0, default: 10 },
  stockQuantity: { type: Number, required: true, min: 0, default: 0 },
  lots: { type: [LotSchema], default: [] },
  isActive: { type: Boolean, default: true },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

ProductSchema.virtual('totalStock').get(function () {
  return this.lots.reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
});

ProductSchema.virtual('stockStatus').get(function () {
  const available = this.lots.reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
  if (available === 0) return 'out_of_stock';
  if (available <= this.lowStockThreshold) return 'low_stock';
  return 'in_stock';
});

ProductSchema.pre('save', function () {
  if (this.lots?.length) {
    this.stockQuantity = this.lots.reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
  }
});

ProductSchema.index({ name: 1 });
ProductSchema.index({ category: 1 });
ProductSchema.index({ 'lots.expirationDate': 1 });

module.exports = mongoose.model('Product', ProductSchema);
