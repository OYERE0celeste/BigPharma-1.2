const mongoose = require("mongoose");
const User = require("../../../models/User");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function listUsers() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    const users = await User.find({}, "fullName email role companyId isActive").lean();
    console.log(JSON.stringify(users, null, 2));
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

listUsers();
