const mongoose = require("mongoose");

const ReviewResponseSchema = new mongoose.Schema(
  {
    message: {
      type: String,
      trim: true,
      maxlength: 1000,
    },
    respondedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    responderName: {
      type: String,
      trim: true,
    },
    respondedAt: {
      type: Date,
    },
  },
  { _id: false }
);

const ReviewSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    clientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Client",
      required: true,
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: true,
    },
    productName: {
      type: String,
      required: true,
      trim: true,
    },
    clientName: {
      type: String,
      required: true,
      trim: true,
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      trim: true,
      maxlength: 1000,
      default: "",
    },
    serviceRating: {
      type: Number,
      min: 1,
      max: 5,
    },
    serviceComment: {
      type: String,
      trim: true,
      maxlength: 1000,
      default: "",
    },
    dissatisfactionLevel: {
      type: String,
      enum: ["aucune", "legere"],
      default: "aucune",
    },
    wouldRecommend: {
      type: Boolean,
      default: true,
    },
    response: {
      type: ReviewResponseSchema,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

ReviewSchema.index({ productId: 1, createdAt: -1 });
ReviewSchema.index({ companyId: 1, createdAt: -1 });
ReviewSchema.index({ userId: 1, createdAt: -1 });
ReviewSchema.index({ clientId: 1, productId: 1, orderId: 1 }, { unique: true });

module.exports = mongoose.models.Review || mongoose.model("Review", ReviewSchema);
