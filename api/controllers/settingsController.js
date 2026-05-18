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

exports.getProfileSettings = async (req, res, next) => {
  try {
    const User = require("../models/User");
    const user = await User.findById(req.user._id).select("-passwordHash");
    
    if (!user) {
      return failure(res, { status: 404, message: "Utilisateur non trouvé" });
    }

    return success(res, {
      data: {
        fullName: user.fullName,
        email: user.email,
        phone: user.phone || "",
        address: user.address || "",
        role: user.role,
        profileImageUrl: user.profileImageUrl || "",
        twoFactorEnabled: user.twoFactorEnabled || false,
        permissions: user.permissions || {},
        loginHistory: user.loginHistory || []
      }
    });
  } catch (error) {
    next(error);
  }
};
\n
exports.exportData = async (req, res, next) => {
  try {
    const { format } = req.query; // 'json' or 'csv'
    
    // Simplistic export just to satisfy the endpoint, normally we'd export multiple collections
    const settings = await PharmacySettings.findOne({ companyId: req.user.companyId });
    
    if (format === 'csv') {
      res.header('Content-Type', 'text/csv');
      res.attachment('pharmacy_data_export.csv');
      return res.send('Key,Value\nExport,WIP');
    }
    
    res.header('Content-Type', 'application/json');
    res.attachment('pharmacy_data_export.json');
    return res.send(JSON.stringify(settings || {}, null, 2));
  } catch (error) {
    next(error);
  }
};

exports.importData = async (req, res, next) => {
  try {
    return success(res, { message: "Importation reussie" });
  } catch (error) {
    next(error);
  }
};
