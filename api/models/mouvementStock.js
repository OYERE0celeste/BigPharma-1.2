const mongoose = require("mongoose");

const MouvementStockSchema = new mongoose.Schema(
  {
    produitId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    lotNumber: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ["entrée", "sortie"],
      required: true,
    },
    quantite: {
      type: Number,
      required: true,
      min: 0,
    },
    beforeQuantity: {
      type: Number,
      required: true,
    },
    afterQuantity: {
      type: Number,
      required: true,
    },
    reason: {
      type: String,
      required: true,
      enum: ["vente", "achat", "retour_client", "retour_fournisseur", "ajustement_manuel", "perte", "expiration", "annulation_vente"],
    },
    referenceId: {
      type: mongoose.Schema.Types.ObjectId,
      required: false, // ID de la vente, de la commande, etc.
    },
    utilisateur: {
      type: String,
      required: true,
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

MouvementStockSchema.index({ companyId: 1 });
MouvementStockSchema.index({ produitId: 1, createdAt: -1 });
MouvementStockSchema.index({ type: 1, createdAt: -1 });

module.exports = mongoose.model("MouvementStock", MouvementStockSchema);
