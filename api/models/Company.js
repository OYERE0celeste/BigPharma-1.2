const mongoose = require("mongoose");

const CompanySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Le nom de l'entreprise est requis"],
      trim: true,
    },
    email: {
      type: String,
      required: [true, "L'email de l'entreprise est requis"],
      unique: true,
      lowercase: true,
      match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, "Veuillez fournir un email valide"],
    },
    phone: {
      type: String,
      required: [true, "Le numéro de téléphone est requis"],
      match: [/^\d+$/, "Le numéro de téléphone ne doit contenir que des chiffres"],
    },
    address: {
      type: String,
      required: [true, "L'adresse est requise"],
    },
    country: {
      type: String,
    },
    city: {
      type: String,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);


module.exports = mongoose.model("Company", CompanySchema);
