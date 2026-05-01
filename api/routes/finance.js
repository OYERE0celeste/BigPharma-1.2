const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Finance = require("../models/finance");
const { logActivity } = require("../utils/activityLogger");

// GET all finance transactions
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 100, startDate, endDate, type, isIncome } = req.query;
    const query = { companyId: req.user.companyId };

    if (startDate || endDate) {
      query.dateTime = {};
      if (startDate) query.dateTime.$gte = new Date(startDate);
      if (endDate) query.dateTime.$lte = new Date(endDate);
    }
    if (type) query.type = type;
    if (isIncome !== undefined) query.isIncome = isIncome === "true" || isIncome === "1";

    const transactions = await Finance.find(query)
      .sort({ dateTime: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await Finance.countDocuments(query);

    res.json({
      success: true,
      data: transactions,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error) {
    next(error);
  }
});

// GET by ID
router.get("/:id", async (req, res, next) => {
  try {
    const transaction = await Finance.findOne({
      _id: req.params.id,
      companyId: req.user.companyId,
    });
    if (!transaction) {
      return res
        .status(404)
        .json({ success: false, message: "Transaction introuvable", code: "NOT_FOUND" });
    }

    res.json({ success: true, data: transaction });
  } catch (error) {
    next(error);
  }
});

// POST create
router.post("/", async (req, res, next) => {
  try {
    const transactionData = { ...req.body, companyId: req.user.companyId };

    // Convert dates if provided
    if (transactionData.dateTime) transactionData.dateTime = new Date(transactionData.dateTime);

    const transaction = new Finance(transactionData);
    const savedTransaction = await transaction.save();

    await logActivity({
      actionType: "create",
      entityType: "finance",
      entityId: savedTransaction._id.toString(),
      entityName: savedTransaction.reference,
      description: `Transaction financière ${savedTransaction.type} créée`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.status(201).json({ success: true, data: savedTransaction });
  } catch (error) {
    next(error);
  }
});

// PUT update
router.put("/:id", async (req, res, next) => {
  try {
    const updated = await Finance.findOneAndUpdate(
      { _id: req.params.id, companyId: req.user.companyId },
      req.body,
      { new: true, runValidators: true }
    );

    if (!updated) {
      return res
        .status(404)
        .json({ success: false, message: "Transaction non trouvée", code: "NOT_FOUND" });
    }

    await logActivity({
      actionType: "update",
      entityType: "finance",
      entityId: updated._id.toString(),
      entityName: updated.reference,
      description: `Transaction financière mise à jour`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, data: updated });
  } catch (error) {
    next(error);
  }
});

// DELETE
router.delete("/:id", async (req, res, next) => {
  try {
    const deleted = await Finance.findOneAndDelete({
      _id: req.params.id,
      companyId: req.user.companyId,
    });
    if (!deleted) {
      return res
        .status(404)
        .json({ success: false, message: "Transaction non trouvée", code: "NOT_FOUND" });
    }

    await logActivity({
      actionType: "delete",
      entityType: "finance",
      entityId: deleted._id.toString(),
      entityName: deleted.reference,
      description: `Transaction financière supprimée`,
      companyId: req.user.companyId,
      user: req.user.fullName,
    });

    res.json({ success: true, message: "Transaction supprimée" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
