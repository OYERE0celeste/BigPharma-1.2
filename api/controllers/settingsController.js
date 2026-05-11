const Settings = require("../models/settings");
const Company = require("../models/Company");
const { success, failure } = require("../utils/response");

exports.getSettings = async (req, res, next) => {
  try {
    let settings = await Settings.findOne({ companyId: req.user.companyId });
    if (!settings) {
      settings = await Settings.create({ companyId: req.user.companyId });
    }

    const company = await Company.findById(req.user.companyId);

    return success(res, { 
      data: { 
        system: settings,
        pharmacy: company
      } 
    });
  } catch (error) {
    next(error);
  }
};

exports.updateSystemSettings = async (req, res, next) => {
  try {
    const settings = await Settings.findOneAndUpdate(
      { companyId: req.user.companyId },
      req.body,
      { new: true, upsert: true }
    );
    return success(res, { data: settings, message: "Paramètres système mis à jour" });
  } catch (error) {
    next(error);
  }
};

exports.updatePharmacyInfo = async (req, res, next) => {
  try {
    const company = await Company.findByIdAndUpdate(
      req.user.companyId,
      req.body,
      { new: true }
    );
    return success(res, { data: company, message: "Informations officine mises à jour" });
  } catch (error) {
    next(error);
  }
};
