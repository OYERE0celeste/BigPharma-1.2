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
  }
},{
  timestamps: true
});

module.exports = mongoose.model("Supplier", SupplierSchema);