const mongoose = require("mongoose");

const ConsultationSchema = new mongoose.Schema({
  client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: true
  },
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  reason: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  diagnosis: {
    type: String,
    trim: true,
    maxlength: 1000
  },
  prescription: {
    type: String,
    trim: true,
    maxlength: 2000
  },
  notes: {
    type: String,
    trim: true,
    maxlength: 2000
  },
  bloodPressure: {
    systolic: { type: Number, min: 0, max: 300 },
    diastolic: { type: Number, min: 0, max: 200 }
  },
  heartRate: {
    type: Number,
    min: 0,
    max: 300
  },
  temperature: {
    type: Number,
    min: 30,
    max: 45
  },
  weight: {
    type: Number,
    min: 0,
    max: 500
  },
  height: {
    type: Number,
    min: 0,
    max: 300
  },
  followUpRequired: {
    type: Boolean,
    default: false
  },
  followUpDate: {
    type: Date
  },
  consultationFee: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  status: {
    type: String,
    enum: ["scheduled", "in_progress", "completed", "cancelled"],
    default: "completed"
  },
  companyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Company",
    required: [true, "La société est requise"],
  },
}, {
  timestamps: true,
});

ConsultationSchema.index({ companyId: 1 });

// Index for efficient queries
ConsultationSchema.index({ client: 1 });
ConsultationSchema.index({ date: -1 });
ConsultationSchema.index({ status: 1 });

module.exports = mongoose.model("Consultation", ConsultationSchema);
