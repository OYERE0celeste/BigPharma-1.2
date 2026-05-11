const User = require("../models/User");
const { success, failure } = require("../utils/response");

exports.getAllStaff = async (req, res, next) => {
  try {
    const staff = await User.find({ 
      companyId: req.user.companyId,
      role: { $ne: 'client' } 
    }).select("-refreshTokens");

    return success(res, { data: staff });
  } catch (error) {
    next(error);
  }
};

exports.createStaff = async (req, res, next) => {
  try {
    const { fullName, email, password, role, phone, address } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return failure(res, {
        status: 400,
        message: "Un utilisateur avec cet email existe déjà",
      });
    }

    const newUser = await User.create({
      fullName,
      email,
      passwordHash: password,
      role,
      companyId: req.user.companyId,
      phone,
      address,
      isActive: true
    });

    // Hide sensitive data
    newUser.passwordHash = undefined;

    return success(res, {
      status: 201,
      data: newUser,
      message: "Employé créé avec succès"
    });
  } catch (error) {
    next(error);
  }
};

exports.updateStaff = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { fullName, role, phone, address, isActive } = req.body;

    const user = await User.findOneAndUpdate(
      { _id: id, companyId: req.user.companyId },
      { fullName, role, phone, address, isActive },
      { new: true, runValidators: true }
    );

    if (!user) {
      return failure(res, {
        status: 404,
        message: "Utilisateur non trouvé",
      });
    }

    return success(res, { data: user });
  } catch (error) {
    next(error);
  }
};

exports.deleteStaff = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Don't allow deleting self
    if (id === req.user._id.toString()) {
      return failure(res, {
        status: 400,
        message: "Vous ne pouvez pas supprimer votre propre compte administrateur",
      });
    }

    const user = await User.findOneAndDelete({ _id: id, companyId: req.user.companyId });

    if (!user) {
      return failure(res, {
        status: 404,
        message: "Utilisateur non trouvé",
      });
    }

    return success(res, { message: "Employé supprimé avec succès" });
  } catch (error) {
    next(error);
  }
};
