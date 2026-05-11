const mongoose = require("mongoose");
const Company = require("../../../models/company");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function listCompanies() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    const companies = await Company.find({}, "name").lean();
    console.log(JSON.stringify(companies, null, 2));
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

listCompanies();
