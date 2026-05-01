const express = require("express");
const router = express.Router();
const ActivityLog = require("../models/activityLog");

// GET /api/activity-logs?entityType=&actionType=&limit=
router.get("/", async (req, res, next) => {
  try {
    const { entityType, actionType, start, end, page = 1, limit = 50 } = req.query;
    const query = { companyId: req.user.companyId };

    if (entityType) query.entityType = entityType;
    if (actionType) query.actionType = actionType;

    if (start || end) {
      query.createdAt = {};
      if (start) query.createdAt.$gte = new Date(start);
      if (end) query.createdAt.$lte = new Date(end);
    }

    const logs = await ActivityLog.find(query)
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit, 10));

    const total = await ActivityLog.countDocuments(query);

    res.json({
      success: true,
      data: logs,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
