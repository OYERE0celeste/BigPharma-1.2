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
      enum: ["client", "product", "consultation", "supplier", "sale"],
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

