const Notification = require("../models/notification");
const { success, failure } = require("../utils/response");
const { sendNotification } = require("../utils/notificationHelper");


exports.getMyNotifications = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);

    const query = { userId: req.user._id };

    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip((page - 1) * limit),
      Notification.countDocuments(query),
      Notification.countDocuments({ ...query, isRead: false }),
    ]);

    return success(res, {
      data: notifications,
      extra: {
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit),
        },
        unreadCount,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return failure(res, {
        status: 404,
        message: "Notification non trouvée",
      });
    }

    return success(res, { data: notification });
  } catch (error) {
    next(error);
  }
};

exports.markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { userId: req.user._id, isRead: false },
      { isRead: true }
    );

    return success(res, { message: "Toutes les notifications ont été marquées comme lues" });
  } catch (error) {
    next(error);
  }
};

exports.deleteNotification = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!notification) {
      return failure(res, {
        status: 404,
        message: "Notification non trouvée",
      });
    }

    return success(res, { message: "Notification supprimée" });
  } catch (error) {
    next(error);
  }
};

exports.sendTestNotification = async (req, res, next) => {
  try {
    const notification = await sendNotification({
      userId: req.user._id,
      companyId: req.user.companyId,
      title: "Notification de test",
      message: "Ceci est une notification de test pour vérifier le système en temps réel.",
      type: "system",
    });

    return success(res, { data: notification, message: "Notification de test envoyée" });
  } catch (error) {
    next(error);
  }
};

