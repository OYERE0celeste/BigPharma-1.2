const express = require("express");
const router = express.Router();
const MouvementStock = require("../models/mouvementStock");

// Liste des mouvements avec filtres et pagination
router.get("/", async (req, res, next) => {
  try {
    const { page = 1, limit = 20, produitId, type, reason, startDate, endDate } = req.query;
    const query = { companyId: req.user.companyId };

    if (produitId) query.produitId = produitId;
    if (type) query.type = type;
    if (reason) query.reason = reason;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const mouvements = await MouvementStock.find(query)
      .populate("produitId", "name")
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await MouvementStock.countDocuments(query);

    res.json({
      success: true,
      data: mouvements,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Export des mouvements en CSV
router.get("/export", async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;
    const query = { companyId: req.user.companyId };

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const mouvements = await MouvementStock.find(query)
      .populate("produitId", "name")
      .sort({ createdAt: -1 });

    let csv = "Date,Produit,Lot,Type,Quantite,Avant,Apres,Raison,Utilisateur\n";

    for (const m of mouvements) {
      csv += `"${m.createdAt.toISOString()}","${m.produitId?.name || "N/A"}","${m.lotNumber}","${m.type}",${m.quantite},${m.beforeQuantity},${m.afterQuantity},"${m.reason}","${m.utilisateur}"\n`;
    }

    res.header("Content-Type", "text/csv");
    res.attachment(`mouvements_stock_${Date.now()}.csv`);
    return res.send(csv);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
