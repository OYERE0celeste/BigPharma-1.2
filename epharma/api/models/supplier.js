const mongoose = require("mongoose");

const SupplierSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  contactName: {
    type: String,
    default: ""
  },
  phone: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true
  },
  address: {
    type: String,
    default: ""
  },
  city: {
    type: String,
    default: ""
  },
  country: {
    type: String,
    default: ""
  },
  notes: {
    type: String,
    default: ""
  },
  status: {
    type: String,
    enum: ["active", "inactive", "suspended"],
    default: "active"
  },
  totalOrders: {
    type: Number,
    default: 0
  },
  totalAmount: {
    type: Number,
    default: 0
  },
  companyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Company",
    required: [true, "La société est requise"],
  },
},{
  timestamps: true
});

SupplierSchema.index({ companyId: 1 });

module.exports = mongoose.model("Supplier", SupplierSchema);