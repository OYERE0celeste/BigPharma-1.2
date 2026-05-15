const User = require("../models/User");

/**
 * Génère un nom d'utilisateur unique à partir d'un fullName.
 * Ex: "Céleste Karma" → "celeste.karma" ou "celeste.karma_42" si pris.
 *
 * @param {string} fullName
 * @returns {Promise<string>} username unique
 */
const generateUsername = async (fullName) => {
  // Normalize: lowercase, remove accents, replace spaces with dots, keep only [a-z0-9_.]
  const base = fullName
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "") // remove diacritics
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ".")           // spaces → dots
    .replace(/[^a-z0-9_.]/g, "")   // remove invalid chars
    .replace(/\.{2,}/g, ".")        // collapse multiple dots
    .replace(/^\.+|\.+$/g, "")      // trim leading/trailing dots
    .substring(0, 25);              // cap base length

  if (!base || base.length < 3) {
    // Fallback if fullName is too short/weird
    return `user_${Date.now().toString(36)}`;
  }

  // Check if base is available
  const exists = await User.findOne({ username: base }).lean();
  if (!exists) return base;

  // Try base + random suffix up to 10 times
  for (let i = 0; i < 10; i++) {
    const suffix = Math.floor(10 + Math.random() * 990); // 10–999
    const candidate = `${base}_${suffix}`.substring(0, 30);
    const taken = await User.findOne({ username: candidate }).lean();
    if (!taken) return candidate;
  }

  // Last resort: timestamp suffix
  return `${base}_${Date.now().toString(36)}`.substring(0, 30);
};

module.exports = { generateUsername };
