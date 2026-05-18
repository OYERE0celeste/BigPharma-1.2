const cron = require("node-cron");
const Product = require("../models/product");
const { logActivity } = require("./activityLogger");
const { notifyStaff } = require("./notificationHelper");

/**
 * Exécute le scan de stock & expiration immédiatement.
 * Renvoie un résumé des résultats pour usage programmatique.
 */
async function runStockExpirationScan() {
  console.log("--- Running Stock & Expiration Scan (manual/boot) ---");
  const result = {
    expiredCount: 0,
    nearExpirationCount: 0,
    lowStockCount: 0,
  };

  try {
    const activeProducts = await Product.find({ isActive: true });

    const expiredProducts = [];
    const nearExpirationProducts = [];
    const lowStockProducts = [];

    for (const p of activeProducts) {
      const expStatus = p.expirationStatus;
      if (expStatus === "EXPIRÉ") {
        expiredProducts.push(p);
      } else if (expStatus === "BIENTÔT EXPIRÉ") {
        nearExpirationProducts.push(p);
      }

      const availableStock = (p.lots || []).reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);
      if (availableStock === 0 || availableStock <= (p.minStockLevel || 10)) {
        lowStockProducts.push(p);
      }
    }

    result.expiredCount = expiredProducts.length;
    result.nearExpirationCount = nearExpirationProducts.length;
    result.lowStockCount = lowStockProducts.length;

    if (expiredProducts.length > 0 || nearExpirationProducts.length > 0 || lowStockProducts.length > 0) {
      await logActivity({
        actionType: "update",
        entityType: "product",
        entityId: "system",
        entityName: "Stock Monitor",
        description: `Scan: ${expiredProducts.length} produits expirés, ${nearExpirationProducts.length} proches d'expiration, ${lowStockProducts.length} en stock faible.`,
        companyId: null,
        user: "System Monitor",
      });

      const companyIds = new Set([
        ...expiredProducts.map((p) => p.companyId && p.companyId.toString()),
        ...lowStockProducts.map((p) => p.companyId && p.companyId.toString()),
      ].filter(Boolean));

      for (const companyId of companyIds) {
        await notifyStaff({
          companyId,
          title: "Alerte Stock",
          message: "Des produits sont expirés ou en stock faible. Veuillez consulter l'inventaire.",
          type: "stock",
        });
      }
    }

    console.log(`Scan complete. Found ${result.expiredCount} expired, ${result.nearExpirationCount} near, ${result.lowStockCount} low stock.`);
    return result;
  } catch (error) {
    console.error("Error during stock/expiration scan:", error);
    throw error;
  }
}

const initCronJobs = () => {
  const enabled = process.env.ENABLE_STOCK_CRON !== "false"; // default enabled
  const schedule = process.env.STOCK_CRON_SCHEDULE || "0 8 * * *"; // default daily at 08:00

  if (!enabled) {
    console.log("Stock cron jobs disabled via ENABLE_STOCK_CRON=false");
    return;
  }

  try {
    cron.schedule(schedule, async () => {
      console.log(`--- Running scheduled Stock & Expiration Scan (${schedule}) ---`);
      try {
        await runStockExpirationScan();
      } catch (err) {
        console.error("Scheduled scan failed:", err);
      }
    });

    // Also run one scan at startup so the system becomes operational immediately
    runStockExpirationScan().catch((err) => console.error("Initial stock scan failed:", err));

    console.log(`Stock cron scheduled (${schedule}) and initial scan triggered.`);
  } catch (err) {
    console.error("Failed to initialize cron jobs:", err);
  }
};

module.exports = { initCronJobs, runStockExpirationScan };
