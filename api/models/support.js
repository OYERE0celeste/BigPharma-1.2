const mongoose = require("mongoose");

const MessageSchema = new mongoose.Schema(
  {
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    senderType: {
      type: String,
      enum: ["client", "pharmacie"],
      required: true,
    },
    content: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { timestamps: true }
);

const SupportQuestionSchema = new mongoose.Schema(
  {
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
    subject: {
      type: String,
      required: true,
      trim: true,
      default: "Question générale"
    },
    status: {
      type: String,
      enum: ["en_attente", "repondu", "ferme"],
      default: "en_attente",
    },
    messages: [MessageSchema],
  },
  { timestamps: true }
);

SupportQuestionSchema.index({ companyId: 1, createdAt: -1 });
SupportQuestionSchema.index({ clientId: 1, createdAt: -1 });

module.exports = mongoose.model("SupportQuestion", SupportQuestionSchema);
