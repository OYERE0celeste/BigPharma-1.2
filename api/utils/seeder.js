const User = require("../models/User");
const Company = require("../models/Company");
const logger = require("./logger");

/**
 * Seeds a default administrator and company if none exist.
 */
async function seedAdmin() {
  try {
    // 1. Ensure a default company exists
    let company = await Company.findOne({ email: "contact@bigpharma.com" });
    if (!company) {
      company = await Company.create({
        name: "BigPharma HQ",
        email: "contact@bigpharma.com",
        phone: "22900000000",
        address: "Avenue de la Santé, Cotonou",
        city: "Cotonou",
        country: "Bénin",
      });
      logger.info("[SEED] Default company created.");
    }

    // 2. Ensure a default admin exists
    const adminEmail = "laflorale@gmail.com";
    const adminExists = await User.findOne({ email: adminEmail });
    
    if (!adminExists) {
      await User.create({
        fullName: "Administrateur Système",
        email: adminEmail,
        passwordHash: "administrateur", // Will be hashed by pre-save hook
        role: "administrateur",
        companyId: company._id,
        isActive: true,
      });
      logger.info(`[SEED] Default administrator created: ${adminEmail} / admin`);
    }
  } catch (error) {
    logger.error("[SEED] Error seeding default admin:", error);
  }
}

module.exports = { seedAdmin };
