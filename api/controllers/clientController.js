const Client = require("../models/client");
const User = require("../models/User");
const { logActivity } = require("../utils/activityLogger");
const { success, failure } = require("../utils/response");
const { sendClientWelcomeEmail } = require("../utils/mailService");

/**
 * Get all clients (Global visibility)
 */
exports.getClients = async (req, res, next) => {
  try {
    const { page = 1, limit = 10, search, gender, companyId } = req.query;

    let query = { isActive: true };

    if (companyId) {
      query.companyId = companyId;
    }

    if (gender) query.gender = gender;
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: "i" } },
        { phone: { $regex: search, $options: "i" } },
        { email: { $regex: search, $options: "i" } },
      ];
    }

    const clients = await Client.find(query)
      .populate("companyId", "name")
      .populate("userId", "fullName email")
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Client.countDocuments(query);

    return success(res, {
      data: clients,
      extra: {
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get client by ID (Admin only)
 */
exports.getClientById = async (req, res, next) => {
  try {
    const client = await Client.findOne({ _id: req.params.id, companyId: req.user.companyId })
      .populate("companyId", "name")
      .populate("userId", "fullName email");

    if (!client) {
      return failure(res, {
        status: 404,
        message: "Client not found",
        code: "CLIENT_NOT_FOUND",
      });
    }

    return success(res, { data: client });
  } catch (error) {
    next(error);
  }
};

/**
 * Create a client
 */
exports.createClient = async (req, res, next) => {
  try {
    const { fullName, email, phone, dateOfBirth, gender, address, createUser, password } = req.body;

    // Validate required fields
    if (!fullName || !phone) {
      return failure(res, {
        status: 400,
        message: "Missing required fields: fullName, phone",
        code: "VALIDATION_ERROR",
      });
    }

    // Normalize email and phone
    const normalizedEmail = email ? email.trim().toLowerCase() : "";
    const normalizedPhone = phone ? phone.trim() : "";

    // Check for duplicate phone/email (case-insensitive for email)
    const existing = await Client.findOne({
      $or: [
        normalizedPhone ? { phone: normalizedPhone } : null,
        normalizedEmail ? { email: { $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' } } : null,
      ].filter(Boolean),
      companyId: req.user.companyId,
    });

    if (existing) {
      return failure(res, {
        status: 409,
        message: "Client with this email or phone already exists",
        code: "DUPLICATE_ENTRY",
      });
    }

    let userId = null;

    // Create User if requested
    if (createUser) {
      if (!email || !password) {
        return failure(res, {
          status: 400,
          message: "Email and password required to create user",
          code: "VALIDATION_ERROR",
        });
      }

      if (typeof password !== "string" || password.length < 8) {
        return failure(res, {
          status: 400,
          message: "Password must be at least 8 characters long",
          code: "VALIDATION_ERROR",
        });
      }

      const user = await User.create({
        fullName: fullName.trim(),
        email: normalizedEmail,
        passwordHash: password,
        role: "client",
        phone: normalizedPhone,
        address: (address || "").trim(),
        companyId: req.user.companyId,
      });
      userId = user._id;

      await sendClientWelcomeEmail({
        email: normalizedEmail,
        fullName: fullName.trim(),
        companyName: "votre pharmacie",
      });
    }

    const clientData = {
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: normalizedPhone,
      dateOfBirth,
      gender,
      address: (address || "").trim(),
      companyId: req.user.companyId,
      userId,
    };

    const client = await Client.create(clientData);

    await logActivity({
      actionType: "create",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `New client created: ${client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { status: 201, data: client });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a client
 */
exports.updateClient = async (req, res, next) => {
  try {
    // Don't allow direct modification of certain fields
    const { companyId, userId, createdAt, ...updateData } = req.body;

    // Normalize email and phone if provided
    if (updateData.email) {
      updateData.email = updateData.email.trim().toLowerCase();
    }
    if (updateData.phone) {
      updateData.phone = updateData.phone.trim();
    }

    // Check for duplicates if email or phone is being updated
    if (updateData.email || updateData.phone) {
      const existing = await Client.findOne({
        _id: { $ne: req.params.id },
        companyId: req.user.companyId,
        $or: [
          updateData.phone ? { phone: updateData.phone } : null,
          updateData.email ? { email: { $regex: `^${updateData.email.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' } } : null,
        ].filter(Boolean),
      });

      if (existing) {
        return failure(res, {
          status: 409,
          message: "Client with this email or phone already exists",
          code: "DUPLICATE_ENTRY",
        });
      }
    }

    const client = await Client.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      updateData,
      { new: true, runValidators: true }
    )
      .populate("companyId", "name")
      .populate("userId", "fullName email");

    if (!client) {
      return failure(res, {
        status: 404,
        message: "Client not found",
        code: "CLIENT_NOT_FOUND",
      });
    }

    await logActivity({
      actionType: "update",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client updated: ${client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { data: client });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a client (soft delete)
 */
exports.deleteClient = async (req, res, next) => {
  try {
    const client = await Client.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      { isActive: false },
      { new: true }
    );

    if (!client) {
      return failure(res, {
        status: 404,
        message: "Client not found",
        code: "CLIENT_NOT_FOUND",
      });
    }

    await logActivity({
      actionType: "delete",
      entityType: "client",
      entityId: client._id.toString(),
      entityName: client.fullName,
      description: `Client deleted: ${client.fullName}`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    return success(res, { data: { message: "Client deleted successfully" } });
  } catch (error) {
    next(error);
  }
};

/**
 * Get profile of the logged-in client
 */
exports.getMyProfile = async (req, res, next) => {
  try {
    // Search for client profile matching the user ID preferred, or email/phone
    const client = await Client.findOne({
      $or: [{ userId: req.user._id }, { email: req.user.email }, { phone: req.user.phone }],
      companyId: req.user.companyId,
    }).populate("companyId", "name");

    if (!client) {
      return failure(res, {
        status: 404,
        message: "Client profile not found",
        code: "PROFILE_NOT_FOUND",
      });
    }

    return success(res, { data: client });
  } catch (error) {
    next(error);
  }
};
