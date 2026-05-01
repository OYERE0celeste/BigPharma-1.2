const ActivityLog = require("../models/activityLog");

/**
 * Enregistre une activité dans la collection ActivityLog.
 * actionType: "create" | "update" | "delete"
 * entityType: "client" | "product" | "consultation" | "supplier" | "sale"
 */
async function logActivity(activityData) {
  try {
    await ActivityLog.create(activityData);
  } catch (err) {
    // On log uniquement l'erreur sans casser la requête principale
    console.error("Failed to log activity:", err.message);
  }
}

module.exports = { logActivity };
