const mongoose = require("mongoose");

const ClientSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 120
  },
  phone: {
    type: String,
    required: true,
    trim: true,
    match: [/^[0-9]+$/, "Le téléphone doit contenir uniquement des chiffres"],
    minlength: 8,
    maxlength: 15
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  address: {
    type: String,
    default: "",
    trim: true,
    maxlength: 200
  },
  gender: {
    type: String,
    required: true,
    enum: ["male", "female"]
  },
  hasMedicalHistory: {
    type: Boolean,
    required: true,
    default: false
  }
},{
  timestamps: true,
});


module.exports = mongoose.model("Client", ClientSchema);