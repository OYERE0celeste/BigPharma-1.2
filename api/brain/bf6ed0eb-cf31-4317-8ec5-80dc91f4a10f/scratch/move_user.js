const mongoose = require("mongoose");
const User = require("../../../models/User");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function moveUserToDataCompany() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    
    const email = "laflorale@gmail.com";
    const targetCompanyId = "69e36a360f0196816d492fd0";

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      console.error(`User ${email} not found`);
      process.exit(1);
    }

    user.companyId = targetCompanyId;
    await user.save();

    console.log(`User ${email} moved successfully to company ${targetCompanyId}`);
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

moveUserToDataCompany();
