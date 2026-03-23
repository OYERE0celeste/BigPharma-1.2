const express = require("express");
const jwt = require("jsonwebtoken");
const Company = require("../models/Company");
const User = require("../models/User");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

// @desc    S'enregistrer (Créer une pharmacie et son administrateur)
// @route   POST /api/auth/register
// @access  Public
router.post("/register", async (req, res, next) => {
  const { name, email, phone, address, city, country, fullName, adminEmail, password } = req.body;

  try {
    // 1. Valider que l'email n'est pas déjà pris
    const userExists = await User.findOne({ email: adminEmail.toLowerCase() });
    if (userExists) {
      return res.status(400).json({ success: false, message: "Un utilisateur avec cet email existe déjà", code: "USER_EXISTS" });
    }

    // 2. Créer la compagnie
    const company = await Company.create({
      name,
      email,
      phone,
      address,
      city,
      country,
    });

    // 3. Créer l'administrateur lié à la compagnie
    const user = await User.create({
      fullName,
      email: adminEmail.toLowerCase(),
      passwordHash: password,
      role: "admin",
      companyId: company._id,
    });

    // 4. Générer le JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || "votre_secret_tres_securise_bigpharma_2024", {
      expiresIn: "30d",
    });

    res.status(201).json({
      success: true,
      token,
      data: {
        user: {
          id: user._id,
          fullName: user.fullName,
          email: user.email,
          role: user.role,
        },
        company: {
          id: company._id,
          name: company.name,
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Se connecter
// @route   POST /api/auth/login
// @access  Public
router.post("/login", async (req, res, next) => {
  const { email, password } = req.body;

  try {
    // 1. Vérifier si l'utilisateur existe
    const user = await User.findOne({ email: email.toLowerCase() }).select("+passwordHash");
    if (!user) {
      return res.status(401).json({ success: false, message: "Identifiants invalides", code: "AUTH_FAILED" });
    }

    // 2. Vérifier si l'utilisateur est actif
    if (!user.isActive) {
      return res.status(401).json({ success: false, message: "Compte désactivé", code: "ACCOUNT_DISABLED" });
    }

    // 3. Comparer les mots de passe
    console.log(`[Auth] Comparing password for user: ${user.email}`);
    const isMatch = await user.matchPassword(password);
    console.log(`[Auth] Password check complete: ${isMatch}`);
    if (!isMatch) {
      console.log(`[Auth] Invalid credentials for: ${user.email}`);
      return res.status(401).json({ success: false, message: "Identifiants invalides", code: "AUTH_FAILED" });
    }

    // 4. Mettre à jour lastLoginAt
    console.log(`[Auth] Updating lastLoginAt...`);
    await User.updateOne({ _id: user._id }, { lastLoginAt: Date.now() });

    // 5. Générer le JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || "votre_secret_tres_securise_bigpharma_2024", {
      expiresIn: "30d",
    });

    // Peupler la compagnie pour le retour
    console.log(`[Auth] Fetching populated user data...`);
    const populatedUser = await User.findById(user._id).populate("companyId");

    if (!populatedUser || !populatedUser.companyId) {
      console.error(`[Auth] Failed to load company data for user: ${user._id}`);
      return res.status(500).json({ success: false, message: "Erreur de chargement des données utilisateur", code: "DATA_LOAD_ERROR" });
    }

    console.log(`[Auth] Success! Sending response for ${user.email}`);
    res.json({
      success: true,
      token,
      data: {
        user: {
          id: populatedUser._id,
          fullName: populatedUser.fullName,
          email: populatedUser.email,
          role: populatedUser.role,
          companyId: populatedUser.companyId._id,
        },
        company: populatedUser.companyId,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Obtenir l'utilisateur actuel
// @route   GET /api/auth/me
// @access  Private
router.get("/me", authMiddleware, async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate("companyId");
    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
