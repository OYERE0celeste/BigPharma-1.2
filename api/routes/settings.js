const express = require("express");

const User = require("../models/User");
const authorizeRoles = require("../middleware/authorizeRoles");
const { success, failure } = require("../utils/response");

const router = express.Router();

const mapSettingsPayload = (user) => ({
  fullName: user.fullName,
  email: user.email,
  role: user.role,
  profileImageUrl: "",
  twoFactorEnabled: Boolean(user.twoFactorEnabled),
  permissions: Object.fromEntries(user.permissions || []),
  loginHistory: [
    {
      date: user.lastLoginAt || user.updatedAt || new Date(),
      device: "Unknown",
      success: true,
    },
  ],
});

router.get("/profile", async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select("-passwordHash");
    if (!user) {
      return failure(res, {
        status: 404,
        message: "User not found",
        code: "NOT_FOUND",
      });
    }

    return success(res, {
      message: "Settings loaded",
      code: "OK",
      data: mapSettingsPayload(user),
    });
  } catch (error) {
    return next(error);
  }
});

router.put("/permissions", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const permissions = req.body.permissions;
    if (!permissions || typeof permissions !== "object") {
      return failure(res, {
        status: 400,
        message: "permissions object is required",
        code: "VALIDATION_ERROR",
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return failure(res, {
        status: 404,
        message: "User not found",
        code: "NOT_FOUND",
      });
    }

    user.permissions = permissions;
    await user.save();

    return success(res, {
      message: "Permissions updated",
      code: "UPDATED",
      data: { permissions: Object.fromEntries(user.permissions || []) },
    });
  } catch (error) {
    return next(error);
  }
});

router.put("/2fa", async (req, res, next) => {
  try {
    const { enabled } = req.body;
    const featureEnabled = process.env.FEATURE_2FA_ENABLED === "true";

    if (!featureEnabled) {
      return success(res, {
        message: "2FA feature is disabled by configuration",
        code: "FEATURE_DISABLED",
        data: { enabled: false, featureFlag: false },
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return failure(res, {
        status: 404,
        message: "User not found",
        code: "NOT_FOUND",
      });
    }

    user.twoFactorEnabled = Boolean(enabled);
    await user.save();

    return success(res, {
      message: "2FA updated",
      code: "UPDATED",
      data: { enabled: user.twoFactorEnabled, featureFlag: true },
    });
  } catch (error) {
    return next(error);
  }
});

router.post("/backup", authorizeRoles(["admin"]), async (req, res) => {
  return success(res, {
    status: 202,
    message: "Backup accepted. Basic backup endpoint stub is active.",
    code: "ACCEPTED",
    data: { accepted: true },
  });
});

router.post("/restore", authorizeRoles(["admin"]), async (req, res) => {
  return success(res, {
    status: 202,
    message: "Restore accepted. Basic restore endpoint stub is active.",
    code: "ACCEPTED",
    data: { accepted: true },
  });
});

router.post("/export", authorizeRoles(["admin"]), async (req, res) => {
  const format = (req.body.format || "json").toString().toLowerCase();

  if (!["json", "csv"].includes(format)) {
    return failure(res, {
      status: 400,
      message: "Supported export formats are json and csv",
      code: "VALIDATION_ERROR",
    });
  }

  return success(res, {
    message: "Export accepted",
    code: "ACCEPTED",
    data: {
      format,
      generatedAt: new Date().toISOString(),
      content: format === "json" ? "{}" : "column\nvalue",
    },
  });
});

router.post("/import", authorizeRoles(["admin"]), async (req, res) => {
  const format = (req.body.format || "json").toString().toLowerCase();
  return success(res, {
    status: 202,
    message: "Import accepted. Basic import endpoint stub is active.",
    code: "ACCEPTED",
    data: { accepted: true, format },
  });
});

module.exports = router;
