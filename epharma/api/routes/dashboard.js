const express = require("express");
const router = express.Router();
const Client = require("../models/client");
const Supplier = require("../models/supplier");
const Product = require("../models/product");
const Consultation = require("../models/consultation");
const Sale = require("../models/sale");
const ActivityLog = require("../models/activityLog");

// GET /api/dashboard/summary
router.get("/summary", async (req, res, next) => {
  try {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const companyQuery = { companyId: req.user.companyId };

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
      Client.countDocuments(companyQuery),
      Supplier.countDocuments(companyQuery),
      Product.countDocuments({ ...companyQuery, isActive: true }),
      Consultation.countDocuments(companyQuery),
      Sale.countDocuments({ ...companyQuery, status: 'active' }),
      Product.countDocuments({ 
        ...companyQuery,
        isActive: true,
        $expr: { $lte: ["$stockQuantity", "$minStockLevel"] },
        stockQuantity: { $gt: 0 }
      }),
      Product.countDocuments({ ...companyQuery, isActive: true, stockQuantity: 0 }),
      ActivityLog.countDocuments({ ...companyQuery, createdAt: { $gte: startOfToday } }),
      ActivityLog.countDocuments({
        ...companyQuery,
        entityType: "client",
        actionType: "create",
        createdAt: { $gte: startOfToday },
      }),
      ActivityLog.countDocuments({
        ...companyQuery,
        entityType: "consultation",
        actionType: "create",
        createdAt: { $gte: startOfToday },
      }),
      Sale.aggregate([
        { $match: { ...companyQuery, saleDate: { $gte: startOfToday }, status: 'active' } },
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
    next(err);
  }
});

module.exports = router;

