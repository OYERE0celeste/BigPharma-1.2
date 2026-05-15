const User = require("../models/User");
const { success, failure } = require("../utils/response");
const {
  getRoleDefaults,
  sanitizePermissionInput,
  resolveUserPermissions,
} = require("../utils/rolePermissions");
const { sendStaffWelcomeEmail } = require("../utils/mailService");

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
    const normalizedEmail = email.trim().toLowerCase();

    if (!password || typeof password !== "string" || password.length < 8) {
      return failure(res, {
        status: 400,
        message: "Password must be at least 8 characters long",
        code: "VALIDATION_ERROR",
      });
    }

    // Check for existing email (case-insensitive)
    const existingUser = await User.findOne({
      email: { $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
    });
    if (existingUser) {
      return failure(res, {
        status: 400,
        message: "Un utilisateur avec cet email existe deja",
        code: "EMAIL_ALREADY_IN_USE",
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
      fullName: fullName.trim(),
      email: normalizedEmail,
      passwordHash: password,
      role,
      companyId: req.user.companyId,
      phone: (phone || "").trim(),
      address: (address || "").trim(),
      isActive: true,
      permissions: sanitizePermissionInput(
        role,
        permissions || getRoleDefaults(role)
      ),
    });

    await sendStaffWelcomeEmail({
      email: normalizedEmail,
      fullName: fullName.trim(),
      companyName: "votre pharmacie",
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
    const { fullName, email, role, phone, address, isActive, permissions } = req.body;

    const existingUser = await User.findOne({ _id: id, companyId: req.user.companyId });
    if (!existingUser) {
      return failure(res, {
        status: 404,
        message: "Utilisateur non trouve",
      });
    }

    // Handle email update with uniqueness check
    if (email) {
      const normalizedEmail = email.trim().toLowerCase();
      const currentEmail = (existingUser.email || "").toLowerCase().trim();

      if (normalizedEmail !== currentEmail) {
        const emailConflict = await User.findOne({
          email: { $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
          _id: { $ne: id },
        });
        if (emailConflict) {
          return failure(res, {
            status: 409,
            message: "Un utilisateur avec cet email existe deja",
            code: "EMAIL_ALREADY_IN_USE",
          });
        }
      }
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

    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName.trim();
    if (email !== undefined) updateData.email = email.trim().toLowerCase();
    if (role !== undefined) updateData.role = role;
    if (phone !== undefined) updateData.phone = phone.trim();
    if (address !== undefined) updateData.address = address.trim();
    if (isActive !== undefined) updateData.isActive = isActive;

    const nextRole = role || existingUser.role;

    if (permissions !== undefined) {
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

    if (global.io) {
      const companyId = user.companyId?.toString?.() || req.user.companyId.toString();
      const userId = user._id.toString();

      global.io.to(companyId).emit("staff-updated", {
        user: payload,
        message: "Un utilisateur a ete mis a jour",
      });
      global.io.to(userId).emit("user-updated", {
        user: payload,
        message: "Vos permissions ont ete mises a jour",
      });
    }

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
