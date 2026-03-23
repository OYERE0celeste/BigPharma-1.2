const express = require("express");
const User = require("../models/User");
const authMiddleware = require("../middleware/authMiddleware");
const authorizeRoles = require("../middleware/authorizeRoles");

const router = express.Router();

// @desc    Créer un utilisateur (Administrateur seulement)
// @route   POST /api/users
// @access  Private/Admin
router.post("/", authorizeRoles(["admin"]), async (req, res, next) => {
  const { fullName, email, password, role } = req.body;

  try {
    // Vérifier si l'utilisateur existe déjà
    const userExists = await User.findOne({ email: email.toLowerCase() });
    if (userExists) {
      return res.status(400).json({ success: false, message: "Un utilisateur avec cet email existe déjà", code: "USER_EXISTS" });
    }

    // Créer l'utilisateur rattaché à la même compagnie que l'administrateur
    const user = await User.create({
      fullName,
      email: email.toLowerCase(),
      passwordHash: password,
      role,
      companyId: req.user.companyId,
    });

    res.status(201).json({
      success: true,
      data: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Lister les utilisateurs de la compagnie
// @route   GET /api/users
// @access  Private/Admin
router.get("/", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = { companyId: req.user.companyId };
    if (req.query.isActive !== undefined) {
      query.isActive = req.query.isActive === "true";
    }

    const users = await User.find(query)
      .select("-passwordHash")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await User.countDocuments(query);

    res.json({
      success: true,
      data: users,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Mettre à jour un utilisateur
// @route   PUT /api/users/:id
// @access  Private/Admin
router.put("/:id", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: "Utilisateur non trouvé", code: "NOT_FOUND" });
    }

    // Vérifier si l'utilisateur appartient à la même compagnie
    if (user.companyId.toString() !== req.user.companyId.toString()) {
      return res.status(403).json({ success: false, message: "Non autorisé", code: "ACCESS_DENIED" });
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

    res.json({
      success: true,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Désactiver un utilisateur (Le supprimer logiquement)
// @route   DELETE /api/users/:id
// @access  Private/Admin
router.delete("/:id", authorizeRoles(["admin"]), async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: "Utilisateur non trouvé", code: "NOT_FOUND" });
    }

    // Vérifier si l'utilisateur appartient à la même compagnie
    if (user.companyId.toString() !== req.user.companyId.toString()) {
      return res.status(403).json({ success: false, message: "Non autorisé", code: "ACCESS_DENIED" });
    }

    user.isActive = false;
    await user.save();

    res.json({ success: true, message: "Utilisateur désactivé" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
