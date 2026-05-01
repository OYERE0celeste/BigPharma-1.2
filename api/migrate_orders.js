const mongoose = require("mongoose");
const Order = require("./models/order");
require("dotenv").config();

const migrate = async () => {
  try {
    const dbUri = process.env.MONGODB_URI || "mongodb://localhost:27017/bigpharma";
    console.log(`Connecting to ${dbUri}...`);
    await mongoose.connect(dbUri);
    console.log("Connected to database");

    // Orders in 'en_preparation' or 'en_livraison' -> 'annulee'
    const result1 = await Order.updateMany(
      { status: { $in: ["en_preparation", "en_livraison"] } },
      { $set: { status: "annulee" } }
    );
    console.log(`Migrated ${result1.modifiedCount} preparation/delivery orders to annulee`);

    // Orders in 'livree' -> 'validee'
    const result2 = await Order.updateMany({ status: "livree" }, { $set: { status: "validee" } });
    console.log(`Migrated ${result2.modifiedCount} livree orders to validee`);

    console.log("Migration completed successfully");
    process.exit(0);
  } catch (error) {
    console.error("Migration failed:", error);
    process.exit(1);
  }
};

migrate();
