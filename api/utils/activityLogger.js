const ActivityLog = require("../models/activityLog");

/**
 * Enregistre une activité dans la collection ActivityLog.
 * actionType: "create" | "update" | "delete"
 * entityType: "client" | "product" | "supplier" | "sale"
 */
async function logActivity(activityData, req = null) {
  try {
    if (req) {
      activityData.ipAddress = req.ip || req.headers["x-forwarded-for"] || req.socket.remoteAddress;
      activityData.userAgent = req.headers["user-agent"];
    }
    await ActivityLog.create(activityData);
  } catch (err) {
    console.error("Failed to log activity:", err.message);
  }
}

module.exports = { logActivity };
