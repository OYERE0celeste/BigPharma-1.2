const mongoose = require("mongoose");

const ActivityLogSchema = new mongoose.Schema(
  {
    actionType: {
      type: String,
      enum: ["create", "update", "delete"],
      required: true,
    },
    entityType: {
      type: String,
      enum: [
        "client",
        "product",
        "consultation",
        "supplier",
        "sale",
        "user",
        "prescription",
        "finance",
        "system",
        "order",
      ],
      required: true,
    },
    entityId: {
      type: String,
      required: true,
    },
    entityName: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },
    clientOrSupplierName: {
      type: String,
      trim: true,
    },
    productName: {
      type: String,
      trim: true,
    },
    quantity: {
      type: Number,
      default: 0,
    },
    totalAmount: {
      type: Number,
      default: 0,
    },
    paymentMethod: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      trim: true,
    },
    listOfItems: [
      {
        productName: String,
        quantity: Number,
        unitPrice: Number,
        totalPrice: Number,
      },
    ],
    user: {
      type: String,
      default: "system",
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "La société est requise"],
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  }
);

ActivityLogSchema.index({ companyId: 1 });

// Index for efficient queries
ActivityLogSchema.index({ createdAt: -1 });
ActivityLogSchema.index({ entityType: 1, createdAt: -1 });
ActivityLogSchema.index({ actionType: 1, createdAt: -1 });

module.exports = mongoose.model("ActivityLog", ActivityLogSchema);
