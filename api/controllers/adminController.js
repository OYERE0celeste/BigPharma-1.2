const { runStockExpirationScan } = require("../utils/cronJobs");
const { success, failure } = require("../utils/response");

exports.triggerScan = async (req, res, next) => {
  try {
    // Optional: restrict to admin roles in middleware; here we assume auth/tenantEnforcer applied
    const result = await runStockExpirationScan();
    return success(res, { data: result, message: "Scan exécuté" });
  } catch (error) {
    next(error);
  }
};
