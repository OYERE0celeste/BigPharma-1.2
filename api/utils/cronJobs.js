const cron = require("node-cron");
const Product = require("../models/product");
const { logActivity } = require("./activityLogger");

const initCronJobs = () => {
  // Scan quotidien à 8h00
  cron.schedule("0 8 * * *", async () => {
    console.log("--- Running Daily Stock & Expiration Scan ---");
    try {
      const now = new Date();
      const thirtyDaysFromNow = new Date();
      thirtyDaysFromNow.setDate(now.getDate() + 30);

      // 1. Trouver les produits avec des lots expirés
      const expiredProducts = await Product.find({
        isActive: true,
        "lots.expirationDate": { $lt: now },
      });

      // 2. Trouver les produits avec des lots proches d'expiration
      const nearExpirationProducts = await Product.find({
        isActive: true,
        "lots.expirationDate": { $gte: now, $lte: thirtyDaysFromNow },
      });

      // 3. Trouver les produits en rupture de stock ou stock faible
      const lowStockProducts = await Product.find({
        isActive: true,
        $or: [{ stockQuantity: 0 }, { $expr: { $lte: ["$stockQuantity", "$minStockLevel"] } }],
      });

      // Log activity for system awareness (this could trigger emails/notifications in the future)
      if (
        expiredProducts.length > 0 ||
        nearExpirationProducts.length > 0 ||
        lowStockProducts.length > 0
      ) {
        await logActivity({
          actionType: "update",
          entityType: "product",
          entityId: "system",
          entityName: "Stock Monitor",
          description: `Daily Scan: ${expiredProducts.length} produits expirés, ${nearExpirationProducts.length} proches d'expiration, ${lowStockProducts.length} en stock faible.`,
          companyId: null, // Global monitor? Or loop through companies.
          user: "System Monitor",
        });
      }

      console.log(
        `Scan complete. Found ${expiredProducts.length} expired, ${nearExpirationProducts.length} near, ${lowStockProducts.length} low stock.`
      );
    } catch (error) {
      console.error("Error during cron job:", error);
    }
  });
};

module.exports = { initCronJobs };
