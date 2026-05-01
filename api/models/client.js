const mongoose = require("mongoose");

const ClientSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 120,
    },
    phone: {
      type: String,
      required: true,
      trim: true,
      set: (v) => require("../utils/encryption").encrypt(v),
      get: (v) => require("../utils/encryption").decrypt(v),
    },
    dateOfBirth: {
      type: Date,
      required: true,
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
    },
    address: {
      type: String,
      default: "",
      trim: true,
      maxlength: 500,
      set: (v) => require("../utils/encryption").encrypt(v),
      get: (v) => require("../utils/encryption").decrypt(v),
    },
    gender: {
      type: String,
      required: true,
      enum: ["male", "female"],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    totalPurchases: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalSpent: {
      type: Number,
      default: 0,
      min: 0,
    },
    lastVisit: {
      type: Date,
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  },
  {
    timestamps: true,
    toJSON: { getters: true },
    toObject: { getters: true },
  }
);

ClientSchema.index({ companyId: 1 });

module.exports = mongoose.model("Client", ClientSchema);
