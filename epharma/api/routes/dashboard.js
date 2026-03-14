const express = require("express");
const router = express.Router();
const Client = require("../models/client");
const Supplier = require("../models/supplier");
const Product = require("../models/product");
const Consultation = require("../models/consultation");
const Sale = require("../models/sale");
const ActivityLog = require("../models/activityLog");

// GET /api/dashboard/summary
router.get("/summary", async (req, res) => {
  try {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const [
      totalClients,
      totalSuppliers,
      totalProducts,
      totalConsultations,
      totalSales,
      productsLowStock,
      productsOutOfStock,
      activitiesToday,
      newClientsToday,
      newConsultationsToday,
      todaySalesRevenue,
    ] = await Promise.all([
      Client.countDocuments(),
      Supplier.countDocuments(),
      Product.countDocuments({ isActive: true }),
      Consultation.countDocuments(),
      Sale.countDocuments({ status: 'active' }),
      Product.countDocuments({ 
        isActive: true,
        $expr: { $lte: ["$stockQuantity", "$minStockLevel"] },
        stockQuantity: { $gt: 0 }
      }),
      Product.countDocuments({ isActive: true, stockQuantity: 0 }),
      ActivityLog.countDocuments({ createdAt: { $gte: startOfToday } }),
      ActivityLog.countDocuments({
        entityType: "client",
        actionType: "create",
        createdAt: { $gte: startOfToday },
      }),
      ActivityLog.countDocuments({
        entityType: "consultation",
        actionType: "create",
        createdAt: { $gte: startOfToday },
      }),
      Sale.aggregate([
        { $match: { saleDate: { $gte: startOfToday }, status: 'active' } },
        { $group: { _id: null, total: { $sum: "$total" } } }
      ]).then(result => result[0]?.total || 0),
    ]);

    res.json({
      success: true,
      data: {
        totalClients,
        totalSuppliers,
        totalProducts,
        totalConsultations,
        totalSales,
        productsLowStock,
        productsOutOfStock,
        activitiesToday,
        newClientsToday,
        newConsultationsToday,
        todaySalesRevenue,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;

