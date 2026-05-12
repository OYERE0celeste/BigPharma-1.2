const Notification = require("../models/notification");
const User = require("../models/user");

/**
 * Sends a notification to a specific user and emits it via Socket.io
 * @param {Object} params
 * @param {string} params.userId - Target user ID
 * @param {string} params.companyId - Company ID
 * @param {string} params.title - Notification title
 * @param {string} params.message - Notification message
 * @param {string} params.type - Type (order, support, stock, system)
 * @param {Object} params.data - Extra data (orderId, etc.)
 */
const sendNotification = async ({ userId, companyId, title, message, type = "system", data = {} }) => {
  try {
    // 1. Save to Database
    const notification = await Notification.create({
      userId,
      companyId,
      title,
      message,
      type,
      data,
    });

    // 2. Emit via Socket.io
    if (global.io) {
      // Emit to the specific user room
      global.io.to(userId.toString()).emit("notification", notification);
      
      // Also emit a general update to the company room (useful for staff dashboards counters)
      global.io.to(companyId.toString()).emit("notification-update", {
        userId,
        unreadCount: await Notification.countDocuments({ userId, isRead: false })
      });
    }

    return notification;
  } catch (error) {
    console.error("Error sending notification:", error);
  }
};

/**
 * Sends a notification to all staff members of a company
 */
const notifyStaff = async ({ companyId, title, message, type = "system", data = {} }) => {
  try {
    const staffMembers = await User.find({
      companyId,
      role: { $in: ["administrateur", "admin", "pharmacien", "gestionnaire de stock", "agent de vente", "personnel autorisé"] },
    });

    const promises = staffMembers.map((staff) =>
      sendNotification({
        userId: staff._id,
        companyId,
        title,
        message,
        type,
        data,
      })
    );

    await Promise.all(promises);
  } catch (error) {
    console.error("Error notifying staff:", error);
  }
};

module.exports = {
  sendNotification,
  notifyStaff,
};
