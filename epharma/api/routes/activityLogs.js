const express = require("express");
const router = express.Router();
const ActivityLog = require("../models/activityLog");

// GET /api/activity-logs?entityType=&actionType=&limit=
router.get("/", async (req, res) => {
  try {
    const { entityType, actionType, limit = 50 } = req.query;
    const query = {};
    if (entityType) query.entityType = entityType;
    if (actionType) query.actionType = actionType;

    const logs = await ActivityLog.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit, 10));

    res.json({
      success: true,
      data: logs,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;

