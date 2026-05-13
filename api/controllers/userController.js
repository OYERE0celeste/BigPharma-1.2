const User = require("../models/User");
const { success, failure } = require("../utils/response");
const {
  getRoleDefaults,
  sanitizePermissionInput,
  resolveUserPermissions,
} = require("../utils/rolePermissions");

exports.getAllStaff = async (req, res, next) => {
  try {
    const staff = await User.find({
      companyId: req.user.companyId,
      role: { $ne: "client" },
    }).select("-refreshTokens");

    return success(res, {
      data: staff.map((user) => {
        const payload = user.toJSON();
        payload.permissions = resolveUserPermissions(user);
        return payload;
      }),
    });
  } catch (error) {
    next(error);
  }
};

exports.createStaff = async (req, res, next) => {
  try {
    const { fullName, email, password, role, phone, address, permissions } = req.body;
    const normalizedEmail = email.toLowerCase();

    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return failure(res, {
        status: 400,
        message: "Un utilisateur avec cet email existe deja",
      });
    }

    if (role === "assistante de gestion") {
      const activeAssistant = await User.findOne({
        companyId: req.user.companyId,
        role: "assistante de gestion",
        isActive: true,
      });

      if (activeAssistant) {
        return failure(res, {
          status: 400,
          message: "Il ne peut y avoir qu'une seule assistante de gestion active a la fois.",
          code: "SINGLETON_ROLE_ERROR",
        });
      }
    }

    const newUser = await User.create({
      fullName,
      email: normalizedEmail,
      passwordHash: password,
      role,
      companyId: req.user.companyId,
      phone,
      address,
      isActive: true,
      permissions: sanitizePermissionInput(
        role,
        permissions || getRoleDefaults(role)
      ),
    });

    const payload = newUser.toJSON();
    payload.permissions = resolveUserPermissions(newUser);

    return success(res, {
      status: 201,
      data: payload,
      message: "Employe cree avec succes",
    });
  } catch (error) {
    next(error);
  }
};

exports.updateStaff = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { fullName, role, phone, address, isActive, permissions } = req.body;

    const existingUser = await User.findOne({ _id: id, companyId: req.user.companyId });
    if (!existingUser) {
      return failure(res, {
        status: 404,
        message: "Utilisateur non trouve",
      });
    }

    if (role === "assistante de gestion" || isActive === true) {
      const isBecomingAssistant =
        role === "assistante de gestion" && existingUser.role !== "assistante de gestion";
      const isReactivatingAssistant =
        isActive === true &&
        existingUser.role === "assistante de gestion" &&
        !existingUser.isActive;

      if (isBecomingAssistant || isReactivatingAssistant) {
        const activeAssistant = await User.findOne({
          companyId: req.user.companyId,
          role: "assistante de gestion",
          isActive: true,
          _id: { $ne: id },
        });

        if (activeAssistant) {
          return failure(res, {
            status: 400,
            message: "Impossible d'activer ce role : une assistante de gestion est deja active.",
            code: "SINGLETON_ROLE_ERROR",
          });
        }
      }
    }

    const updateData = { fullName, role, phone, address, isActive };
    const nextRole = role || existingUser.role;

    if (permissions) {
      updateData.permissions = sanitizePermissionInput(nextRole, permissions);
    } else if (role && role !== existingUser.role) {
      updateData.permissions = getRoleDefaults(nextRole);
    }

    const user = await User.findOneAndUpdate(
      { _id: id, companyId: req.user.companyId },
      updateData,
      { new: true, runValidators: true }
    );

    if (!user) {
      return failure(res, {
        status: 404,
        message: "Utilisateur non trouve",
      });
    }

    const payload = user.toJSON();
    payload.permissions = resolveUserPermissions(user);

    return success(res, { data: payload });
  } catch (error) {
    next(error);
  }
};

exports.deleteStaff = async (req, res, next) => {
  try {
    const { id } = req.params;

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
        message: "Utilisateur non trouve",
      });
    }

    return success(res, { message: "Employe supprime avec succes" });
  } catch (error) {
    next(error);
  }
};
