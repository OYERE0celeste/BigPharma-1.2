const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Client = require("../models/client");
const Company = require("../models/Company");
const { logActivity } = require("../utils/activityLogger");
const { getJwtSecret } = require("../config/env");
const { success, failure } = require("../utils/response");

// Token durations
const ACCESS_TOKEN_EXPIRY = "15m";
const REFRESH_TOKEN_EXPIRY_DAYS = 7;

const signAccessToken = (userId) => 
  jwt.sign({ id: userId }, getJwtSecret(), { expiresIn: ACCESS_TOKEN_EXPIRY });

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
  email: user.email,
  role: user.role,
  phone: user.phone || "",
  address: user.address || "",
  companyId: user.companyId ? (user.companyId._id || user.companyId).toString() : null,
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

    const existingUser = await User.findOne({ email: adminEmail.toLowerCase() }).lean();
    if (existingUser) {
      return failure(res, { status: 409, message: "User with this email already exists", code: "USER_ALREADY_EXISTS" });
    }

    const company = await Company.create({
      name,
      email: email.toLowerCase(),
      phone,
      address,
      city,
      country,
    });

    const user = await User.create({
      fullName,
      email: adminEmail.toLowerCase(),
      passwordHash: password,
      role: "admin",
      companyId: company._id,
      permissions: { products: true, clients: true, sales: true, finance: true, users: true, settings: true },
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

    const existingUser = await User.findOne({ $or: [{ email: email.toLowerCase() }, { phone }] }).lean();
    if (existingUser) {
      return failure(res, { status: 409, message: "User with this email or phone already exists", code: "USER_ALREADY_EXISTS" });
    }

    const user = await User.create({
      fullName,
      email: email.toLowerCase(),
      passwordHash: password,
      role: "client",
      phone,
      address: address || "",
      companyId,
    });

    const client = await Client.create({
      fullName,
      email: email.toLowerCase(),
      phone,
      dateOfBirth: new Date(dateOfBirth),
      gender,
      address: address || "",
      companyId,
      userId: user._id,
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
  const { email, password } = req.body;

  try {
    if (!email || !password) {
      return failure(res, { status: 400, message: "Email and password are required", code: "VALIDATION_ERROR" });
    }

    const user = await User.findOne({ email: email.toLowerCase() })
      .select("+passwordHash")
      .populate("companyId", "name email");

    if (!user || !(await user.matchPassword(password))) {
      return failure(res, { status: 401, message: "Invalid email or password", code: "INVALID_CREDENTIALS" });
    }

    if (!user.isActive) {
      return failure(res, { status: 403, message: "Account has been deactivated", code: "ACCOUNT_INACTIVE" });
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
 * Forgot password
 */
exports.forgotPassword = async (req, res, next) => {
  const { email } = req.body;

  try {
    if (!email) {
      return failure(res, { status: 400, message: "Email is required", code: "VALIDATION_ERROR" });
    }

    const user = await User.findOne({ email: email.toLowerCase() }).select("+passwordResetToken +passwordResetExpires");

    if (user) {
      const rawToken = crypto.randomBytes(32).toString("hex");
      const tokenHash = crypto.createHash("sha256").update(rawToken).digest("hex");

      user.passwordResetToken = tokenHash;
      user.passwordResetExpires = new Date(Date.now() + 60 * 60 * 1000);
      await user.save();

      if (process.env.NODE_ENV !== "production") {
        return success(res, { data: { resetToken: rawToken, expiresInMinutes: 60 } });
      }
    }

    return success(res, { data: { message: "If the email exists, a reset link has been sent" } });
  } catch (error) {
    next(error);
  }
};

/**
 * Reset password
 */
exports.resetPassword = async (req, res, next) => {
  const { token, password, confirmPassword } = req.body;

  try {
    if (!token || !password || !confirmPassword) {
      return failure(res, { status: 400, message: "Token, password and confirmation are required", code: "VALIDATION_ERROR" });
    }

    if (password !== confirmPassword) {
      return failure(res, { status: 400, message: "Passwords do not match", code: "PASSWORD_MISMATCH" });
    }

    const tokenHash = crypto.createHash("sha256").update(token).digest("hex");

    const user = await User.findOne({
      passwordResetToken: tokenHash,
      passwordResetExpires: { $gt: new Date() },
    }).select("+passwordResetToken +passwordResetExpires +passwordHash");

    if (!user) {
      return failure(res, { status: 400, message: "Invalid or expired reset token", code: "INVALID_RESET_TOKEN" });
    }

    user.passwordHash = password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    return success(res, { data: { message: "Password reset successfully" } });
  } catch (error) {
    next(error);
  }
};

/**
 * Update current user profile
 */
exports.updateMe = async (req, res, next) => {
  try {
    const { fullName, email, phone, address } = req.body;

    const user = await User.findById(req.user._id).populate("companyId", "name");
    if (!user) {
      return failure(res, { status: 404, message: "User not found", code: "USER_NOT_FOUND" });
    }

    if (email && email !== user.email) {
      const newEmail = email.toLowerCase();
      const conflict = await User.findOne({ email: newEmail, _id: { $ne: req.user._id } }).lean();
      if (conflict) {
        return failure(res, { status: 409, message: "Email is already taken", code: "EMAIL_ALREADY_IN_USE" });
      }
      user.email = newEmail;
    }

    if (fullName) user.fullName = fullName;
    if (phone) user.phone = phone;
    if (address) user.address = address;

    await user.save();

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

    return success(res, { data: { message: "Password changed successfully" } });
  } catch (error) {
    next(error);
  }
};
