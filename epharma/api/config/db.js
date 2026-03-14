const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect("mongodb://localhost:27017/BigPharmaDB");
    console.log("MongoDB connecté");
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

module.exports = connectDB;