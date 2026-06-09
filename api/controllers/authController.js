const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Client = require("../models/client");
const Company = require("../models/Company");
const { logActivity } = require("../utils/activityLogger");
const { getJwtSecret } = require("../config/env");
const { success, failure } = require("../utils/response");
const { notifyStaff } = require("../utils/notificationHelper");
const { getRoleDefaults, resolveUserPermissions } = require("../utils/rolePermissions");
const logger = require("../utils/logger");
const { generateUsername } = require("../utils/usernameGenerator");
const {
  sendStaffWelcomeEmail,
  sendClientWelcomeEmail,
  sendPasswordResetEmail,
  sendProfileUpdateEmail,
  sendPasswordChangedEmail,
} = require("../utils/mailService");


// Token durations
const ACCESS_TOKEN_EXPIRY = "15m";
const REFRESH_TOKEN_EXPIRY_DAYS = 7;

const signAccessToken = (userId) =>
  jwt.sign({ id: userId.toString() }, getJwtSecret(), { expiresIn: ACCESS_TOKEN_EXPIRY });

const generateRefreshToken = async (user) => {
  const token = crypto.randomBytes(40).toString("hex");
  const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000);

  user.refreshTokens.push({ token, expiresAt });

  // Keep only the last 5 tokens to avoid document bloat
  if (user.refreshTokens.length > 5) {
    user.refreshTokens.shift();
  }

  await user.save();
  return token;
};

const userPayload = (user) => ({
  id: user._id,
  fullName: user.fullName,
  username: user.username || null,
  email: user.email,
  role: user.role,
  phone: user.phone || "",
  address: user.address || "",
  companyId: user.companyId ? (user.companyId._id || user.companyId).toString() : null,
  isActive: user.isActive !== false,
  permissions: resolveUserPermissions(user),
  lastLoginAt: user.lastLoginAt || null,
});

/**
 * Register a new Admin and Company
 */
exports.register = async (req, res, next) => {
  const { name, email, phone, address, city, country, fullName, adminEmail, password } = req.body;

  try {
    if (!name || !email || !fullName || !adminEmail || !password) {
      return failure(res, { status: 400, message: "Missing required fields", code: "VALIDATION_ERROR" });
    }

    const normalizedAdminEmail = adminEmail.trim().toLowerCase();
    const normalizedCompanyEmail = email.trim().toLowerCase();
    const normalizedPhone = phone ? phone.trim() : "";

    // Check for existing user with case-insensitive email
    const existingUser = await User.findOne({
      email: { $regex: `^${normalizedAdminEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
    }).lean();
    if (existingUser) {
      return failure(res, { status: 409, message: "User with this email already exists", code: "USER_ALREADY_EXISTS" });
    }

    const company = await Company.create({
      name: name.trim(),
      email: normalizedCompanyEmail,
      phone: normalizedPhone,
      address: (address || "").trim(),
      city: (city || "").trim(),
      country: (country || "").trim(),
    });

    const username = await generateUsername(fullName.trim());

    const user = await User.create({
      fullName: fullName.trim(),
      username,
      email: normalizedAdminEmail,
      passwordHash: password,
      role: "administrateur",
      companyId: company._id,
      permissions: getRoleDefaults("administrateur"),
    });

    await sendStaffWelcomeEmail({
      email: normalizedAdminEmail,
      fullName: fullName.trim(),
      companyName: company.name,
    });

    const accessToken = signAccessToken(user._id);
    const refreshToken = await generateRefreshToken(user);

    return success(res, {
      status: 201,
      data: {
        accessToken,
        token: accessToken,
        refreshToken,
        user: userPayload(user),
        company: { id: company._id, name: company.name, email: company.email },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Register a new Client
 */
exports.registerClient = async (req, res, next) => {
  const { fullName, email, phone, password, dateOfBirth, gender, address, companyId } = req.body;

  try {
    if (!fullName || !email || !phone || !password || !dateOfBirth || !gender || !companyId) {
      return failure(res, { status: 400, message: "Missing required fields", code: "VALIDATION_ERROR" });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const normalizedPhone = phone.trim();

    // Check for existing user with case-insensitive email
    const existingUser = await User.findOne({
      $or: [
        { email: { $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' } },
        { phone: normalizedPhone },
      ],
    }).lean();
    if (existingUser) {
      return failure(res, { status: 409, message: "User with this email or phone already exists", code: "USER_ALREADY_EXISTS" });
    }

    const username = await generateUsername(fullName.trim());

    const user = await User.create({
      fullName: fullName.trim(),
      username,
      email: normalizedEmail,
      passwordHash: password,
      role: "client",
      phone: normalizedPhone,
      address: (address || "").trim(),
      companyId,
    });

    const client = await Client.create({
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: normalizedPhone,
      dateOfBirth: new Date(dateOfBirth),
      gender,
      address: (address || "").trim(),
      companyId,
      userId: user._id,
    });

    const company = await Company.findById(companyId).select("name").lean();
    await sendClientWelcomeEmail({
      email: normalizedEmail,
      fullName: fullName.trim(),
      companyName: company?.name || "votre pharmacie",
    });

    const accessToken = signAccessToken(user._id);
    const refreshToken = await generateRefreshToken(user);

    // Notify pharmacy staff of new client registration
    await notifyStaff({
      companyId,
      title: "Nouveau client inscrit",
      message: `${fullName} s'est inscrit en tant que nouveau client.`,
      type: "system",
      data: { clientId: client._id },
    });

    return success(res, {

      status: 201,
      data: {
        accessToken,
        token: accessToken,
        refreshToken,
        user: userPayload(user),
        client: { id: client._id, fullName: client.fullName, email: client.email, phone: client.phone },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login user
 */
exports.login = async (req, res, next) => {
  // Accept `identifier` (email or username) OR legacy `email` field
  const identifier = (req.body.identifier || req.body.email || "").trim().toLowerCase();
  const { password } = req.body;

  try {
    if (!identifier || !password) {
      return failure(res, { status: 400, message: "Identifiant et mot de passe requis", code: "VALIDATION_ERROR" });
    }

    // Detect if identifier looks like an email
    const isEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identifier);

    const query = isEmail
      ? { email: identifier }
      : { username: identifier };

    const user = await User.findOne(query)
      .select("+passwordHash")
      .populate("companyId", "name email");

    if (!user || !(await user.matchPassword(password))) {
      return failure(res, { status: 401, message: "Identifiant ou mot de passe invalide", code: "INVALID_CREDENTIALS" });
    }

    if (!user.isActive) {
      return failure(res, { status: 403, message: "Ce compte a été désactivé", code: "ACCOUNT_INACTIVE" });
    }

    user.lastLoginAt = new Date();
    const accessToken = signAccessToken(user._id);
    const refreshToken = await generateRefreshToken(user);

    return success(res, {
      data: {
        accessToken,
        token: accessToken,
        refreshToken,
        user: userPayload(user),
        company: user.companyId ? { id: user.companyId._id, name: user.companyId.name } : null,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Refresh Token
 */
exports.refreshToken = async (req, res, next) => {
  const { token } = req.body;

  try {
    if (!token) {
      return failure(res, { status: 400, message: "Refresh token is required", code: "VALIDATION_ERROR" });
    }

    const user = await User.findOne({ "refreshTokens.token": token });

    if (!user) {
      return failure(res, { status: 401, message: "Invalid refresh token", code: "INVALID_TOKEN" });
    }

    const refreshToken = user.refreshTokens.find(t => t.token === token);

    if (refreshToken.revokedAt || refreshToken.expiresAt < new Date()) {
      // If token is revoked or expired, we might want to revoke ALL tokens for this user for safety
      user.refreshTokens = [];
      await user.save();
      return failure(res, { status: 401, message: "Token expired or compromised", code: "TOKEN_EXPIRED" });
    }

    // Token Rotation: Generate new tokens and revoke old one
    const newAccessToken = signAccessToken(user._id);
    const newRefreshToken = crypto.randomBytes(40).toString("hex");

    refreshToken.revokedAt = new Date();
    refreshToken.replacedByToken = newRefreshToken;

    user.refreshTokens.push({
      token: newRefreshToken,
      expiresAt: new Date(Date.now() + REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000)
    });

    await user.save();

    return success(res, {
      data: {
        accessToken: newAccessToken,
        token: newAccessToken,
        refreshToken: newRefreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Logout / Revoke Token
 */
exports.logout = async (req, res, next) => {
  const { token } = req.body;

  try {
    if (!token) return success(res); // Already logged out or no token provided

    const user = await User.findOne({ "refreshTokens.token": token });
    if (user) {
      const refreshToken = user.refreshTokens.find(t => t.token === token);
      refreshToken.revokedAt = new Date();
      await user.save();
    }

    return success(res, { message: "Logged out successfully" });
  } catch (error) {
    next(error);
  }
};

/**
 * Get current user
 */
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id)
      .select("-passwordHash")
      .populate("companyId", "name email");

    if (!user) {
      return failure(res, { status: 404, message: "User not found", code: "USER_NOT_FOUND" });
    }

    return success(res, { data: userPayload(user) });
  } catch (error) {
    next(error);
  }
};

/**
 * Forgot password — génère un OTP à 6 chiffres et l'envoie par email
 */
exports.forgotPassword = async (req, res, next) => {
  // Accepte email OU nom d'utilisateur
  const identifier = (req.body.identifier || req.body.email || "").trim().toLowerCase();

  try {
    if (!identifier) {
      return failure(res, { status: 400, message: "Email ou nom d'utilisateur requis", code: "VALIDATION_ERROR" });
    }

    // Cherche par email ou par username
    const isEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identifier);
    const user = await User.findOne(
      isEmail ? { email: identifier } : { username: identifier }
    ).select("+passwordResetToken +passwordResetExpires");

    if (user) {
      // Générer un OTP à 6 chiffres
      const otp = String(Math.floor(100000 + Math.random() * 900000));
      const otpHash = crypto.createHash("sha256").update(otp).digest("hex");

      user.passwordResetToken = otpHash;
      user.passwordResetExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
      await user.save();

      await sendPasswordResetEmail({
        email: user.email,
        fullName: user.fullName,
        token: otp, // L'email affiche le code OTP directement
      });

      logger.info(`OTP de réinitialisation envoyé à ${user.email}`);

      // Keep otp available to include in response in test environment
      res.locals.__testResetOtp = otp;
    }

    // Réponse identique qu'un compte existe ou non (sécurité).
    // In test environment, include the token in the response to allow automated tests to validate reset flows.
    const baseMessage = "Si cet identifiant existe, un code de réinitialisation a été envoyé par email";
    const responseData = { message: baseMessage };
    if (process.env.NODE_ENV === 'test' && res.locals.__testResetOtp) {
      responseData.resetToken = res.locals.__testResetOtp;
    }

    return success(res, { data: responseData });
  } catch (error) {
    next(error);
  }
};

/**
 * Reset password — valide l'OTP et applique le nouveau mot de passe
 */
exports.resetPassword = async (req, res, next) => {
  const { otp, password, confirmPassword } = req.body;
  // Compatibilité avec l'ancien champ `token`
  const code = (otp || req.body.token || "").trim();

  try {
    if (!code || !password) {
      return failure(res, { status: 400, message: "Code OTP et nouveau mot de passe requis", code: "VALIDATION_ERROR" });
    }

    if (password !== (confirmPassword || password)) {
      return failure(res, { status: 400, message: "Les mots de passe ne correspondent pas", code: "PASSWORD_MISMATCH" });
    }

    if (password.length < 8) {
      return failure(res, { status: 400, message: "Le mot de passe doit contenir au moins 8 caractères", code: "VALIDATION_ERROR" });
    }

    const otpHash = crypto.createHash("sha256").update(code).digest("hex");

    const user = await User.findOne({
      passwordResetToken: otpHash,
      passwordResetExpires: { $gt: new Date() },
    }).select("+passwordResetToken +passwordResetExpires +passwordHash");

    if (!user) {
      return failure(res, {
        status: 400,
        message: "Code invalide ou expiré. Veuillez demander un nouveau code.",
        code: "INVALID_RESET_TOKEN",
      });
    }

    user.passwordHash = password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    // Invalider tous les refresh tokens pour sécuriser la session
    user.refreshTokens = [];
    await user.save();

    // Email de confirmation
    sendPasswordChangedEmail({
      email: user.email,
      fullName: user.fullName,
    }).catch((err) => logger.warn("Password changed email failed", err));

    return success(res, { data: { message: "Mot de passe réinitialisé avec succès" } });
  } catch (error) {
    next(error);
  }
};

/**
 * Update current user profile
 */
exports.updateMe = async (req, res, next) => {
  try {
    const { fullName, email, address, username } = req.body;
    const phone = req.body.phone ?? req.body.phoneNumber;

    const user = await User.findById(req.user._id).populate("companyId", "name");
    if (!user) {
      return failure(res, { status: 404, message: "User not found", code: "USER_NOT_FOUND" });
    }

    // Normalize & validate email
    if (email) {
      const normalizedEmail = email.toString().trim().toLowerCase();
      const currentEmail = (user.email || "").toLowerCase().trim();

      if (normalizedEmail !== currentEmail) {
        const conflict = await User.findOne({
          email: { $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
          _id: { $ne: req.user._id },
        }).lean();

        if (conflict) {
          return failure(res, { status: 409, message: "Cet email est déjà utilisé", code: "EMAIL_ALREADY_IN_USE" });
        }
      }
      user.email = normalizedEmail;
    }

    // Normalize & validate username
    if (username !== undefined && username !== null) {
      const normalizedUsername = username.toString().trim().toLowerCase();

      if (normalizedUsername.length < 3 || normalizedUsername.length > 30) {
        return failure(res, { status: 400, message: "Le nom d'utilisateur doit contenir entre 3 et 30 caractères", code: "VALIDATION_ERROR" });
      }
      if (!/^[a-z0-9_.]+$/.test(normalizedUsername)) {
        return failure(res, { status: 400, message: "Le nom d'utilisateur ne peut contenir que des lettres, chiffres, points et underscores", code: "VALIDATION_ERROR" });
      }

      if (normalizedUsername !== (user.username || "")) {
        const usernameTaken = await User.findOne({
          username: normalizedUsername,
          _id: { $ne: req.user._id },
        }).lean();

        if (usernameTaken) {
          return failure(res, { status: 409, message: "Ce nom d'utilisateur est déjà pris", code: "USERNAME_ALREADY_IN_USE" });
        }
        user.username = normalizedUsername;
      }
    }

    if (fullName) user.fullName = fullName.trim();
    if (phone !== undefined) user.phone = phone.trim();
    if (address !== undefined) user.address = address.trim();

    await user.save();

    // Also update Client document if user is a client
    if (user.role === "client") {
      const Client = require("../models/client");
      await Client.findOneAndUpdate(
        { userId: user._id },
        {
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
          address: user.address,
        }
      );
    }

    // Send profile update notification (non-blocking)
    sendProfileUpdateEmail({
      email: user.email,
      fullName: user.fullName,
    }).catch((err) => logger.warn("Profile update email failed", err));

    return success(res, { data: userPayload(user) });
  } catch (error) {
    next(error);
  }
};

/**
 * Change password
 */
exports.changePassword = async (req, res, next) => {
  const { currentPassword, newPassword, confirmPassword } = req.body;

  try {
    if (!currentPassword || !newPassword || !confirmPassword) {
      return failure(res, { status: 400, message: "Current password, new password, and confirmation are required", code: "VALIDATION_ERROR" });
    }

    if (newPassword !== confirmPassword) {
      return failure(res, { status: 400, message: "New password and confirmation do not match", code: "PASSWORD_MISMATCH" });
    }

    const user = await User.findById(req.user._id).select("+passwordHash");
    if (!user) {
      return failure(res, { status: 404, message: "User not found", code: "USER_NOT_FOUND" });
    }

    const isCurrentValid = await user.matchPassword(currentPassword);
    if (!isCurrentValid) {
      return failure(res, { status: 401, message: "Current password is incorrect", code: "INVALID_PASSWORD" });
    }

    user.passwordHash = newPassword;
    await user.save();

    // Send password change confirmation (non-blocking)
    sendPasswordChangedEmail({
      email: user.email,
      fullName: user.fullName,
    }).catch((err) => logger.warn("Password changed email failed", err));

    return success(res, { data: { message: "Password changed successfully" } });
  } catch (error) {
    next(error);
  }
};
