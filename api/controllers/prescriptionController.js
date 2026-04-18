const Prescription = require("../models/prescription");
const { success, failure } = require("../utils/response");

/**
 * Upload a new prescription (Client)
 */
exports.createPrescription = async (req, res, next) => {
  try {
    const { imageUrl, notes, companyId } = req.body;

    if (!imageUrl) {
      return failure(res, { status: 400, message: "L'image de l'ordonnance est requise" });
    }

    const prescription = new Prescription({
      client: req.user._id,
      imageUrl,
      notes,
      companyId, // The client picks which pharmacy to send it to
    });

    await prescription.save();

    return success(res, { status: 201, data: prescription });
  } catch (error) {
    next(error);
  }
};

/**
 * Get current client's prescriptions
 */
exports.getMyPrescriptions = async (req, res, next) => {
  try {
    const prescriptions = await Prescription.find({ client: req.user._id })
      .populate("companyId", "name")
      .sort({ createdAt: -1 });

    return success(res, { data: prescriptions });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all prescriptions (Pharmacy Staff)
 */
exports.getAllPrescriptions = async (req, res, next) => {
  try {
    const prescriptions = await Prescription.find({ companyId: req.user.companyId })
      .populate("client", "fullName email phone")
      .sort({ createdAt: -1 });

    return success(res, { data: prescriptions });
  } catch (error) {
    next(error);
  }
};

/**
 * Validate or Reject a prescription (Pharmacy Staff)
 */
exports.validatePrescription = async (req, res, next) => {
  try {
    const { status, pharmacyNotes } = req.body;
    
    if (!["validated", "rejected"].includes(status)) {
      return failure(res, { status: 400, message: "Statut invalide (validated ou rejected requis)" });
    }

    const prescription = await Prescription.findOne({ 
      _id: req.params.id, 
      companyId: req.user.companyId 
    });

    if (!prescription) {
      return failure(res, { status: 404, message: "Ordonnance non trouvée" });
    }

    prescription.status = status;
    prescription.pharmacyNotes = pharmacyNotes;
    prescription.validatedBy = req.user._id;
    prescription.validatedAt = new Date();

    await prescription.save();

    return success(res, { data: prescription });
  } catch (error) {
    next(error);
  }
};
