const ActivityLog = require("../models/activityLog");

/**
 * Enregistre une activité dans la collection ActivityLog.
 * actionType: "create" | "update" | "delete"
 * entityType: "client" | "product" | "consultation" | "supplier" | "sale"
 */
async function logActivity({
  actionType,
  entityType,
  entityId,
  entityName,
  description,
  user = "system",
}) {
  try {
    await ActivityLog.create({
      actionType,
      entityType,
      entityId,
      entityName,
      description,
      user,
    });
  } catch (err) {
    // On log uniquement l'erreur sans casser la requête principale
    console.error("Failed to log activity:", err.message);
  }
}

module.exports = { logActivity };

