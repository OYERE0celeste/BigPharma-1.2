const mongoose = require("mongoose");

const ConsultationSchema = new mongoose.Schema({
  companyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true
  },
  // TODO: add consultation fields
}, { timestamps: true });

module.exports = mongoose.model('Consultation', ConsultationSchema);