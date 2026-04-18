const express = require("express");
const User = require("../models/User");
const authorizeRoles = require("../middleware/authorizeRoles");
const { success, failure } = require("../utils/response");

const router = express.Router();

router.post("/", authorizeRoles(["admin"]), async (req, res, next) => {
  const { fullName, email, password, role } = req.body;

  try {
    const userExists = await User.findOne({ email: email.toLowerCase() });
    if (userExists) {
      return failure(res, {
        status: 409,
        message: "An account with this email already exists",
        code: "CONFLICT",
      });
    }

    const user = await User.create({
      fullName,
      email: email.toLowerCase(),
      passwordHash: password,
      role,
      companyId: req.user.companyId,
    });

    return success(res, {
      status: 201,
      message: "User created",
      code: "CREATED",
      data: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      },
    });
  } catch (error) {
    return next(error);
  }
});

router.get("/", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    const query = { companyId: req.user.companyId };
    if (req.query.isActive !== undefined) {
      query.isActive = req.query.isActive === "true";
    }

    const [users, total] = await Promise.all([
      User.find(query).select("-passwordHash").skip(skip).limit(limit).sort({ createdAt: -1 }),
      User.countDocuments(query),
    ]);

    return success(res, {
      message: "Users fetched",
      data: users,
      extra: {
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    return next(error);
  }
});

router.put("/:id", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return failure(res, {
        status: 404,
        message: "User not found",
        code: "NOT_FOUND",
      });
    }

    if (user.companyId.toString() !== req.user.companyId.toString()) {
      return failure(res, {
        status: 403,
        message: "Access denied",
        code: "FORBIDDEN",
      });
    }

    const { fullName, email, role, isActive } = req.body;

    if (fullName) user.fullName = fullName;
    if (email) user.email = email.toLowerCase();
    if (role) user.role = role;
    if (isActive !== undefined) user.isActive = isActive;
    if (req.body.password) {
      user.passwordHash = req.body.password;
    }

    await user.save();

    return success(res, {
      message: "User updated",
      code: "UPDATED",
      data: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      },
    });
  } catch (error) {
    return next(error);
  }
});

router.delete("/:id", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return failure(res, {
        status: 404,
        message: "User not found",
        code: "NOT_FOUND",
      });
    }

    if (user.companyId.toString() !== req.user.companyId.toString()) {
      return failure(res, {
        status: 403,
        message: "Access denied",
        code: "FORBIDDEN",
      });
    }

    user.isActive = false;
    await user.save();

    return success(res, {
      message: "User disabled",
      code: "UPDATED",
      data: { id: user._id, isActive: user.isActive },
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
