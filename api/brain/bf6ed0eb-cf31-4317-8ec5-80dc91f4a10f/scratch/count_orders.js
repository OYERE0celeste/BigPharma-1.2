const mongoose = require("mongoose");
const Order = require("../../../models/order");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function countOrdersByCompany() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    const stats = await Order.aggregate([
      { $group: { _id: "$companyId", count: { $sum: 1 } } }
    ]);
    console.log(JSON.stringify(stats, null, 2));
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

countOrdersByCompany();
