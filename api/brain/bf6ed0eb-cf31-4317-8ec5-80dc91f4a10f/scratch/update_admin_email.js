const mongoose = require("mongoose");
const User = require("../../../models/User");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function updateAdminEmail() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    
    const oldEmail = "admin@bigpharma.com";
    const newEmail = "laflorale8@gmail.com";

    const user = await User.findOne({ email: oldEmail.toLowerCase() });
    if (!user) {
      console.error(`User ${oldEmail} not found`);
      process.exit(1);
    }

    user.email = newEmail.toLowerCase();
    await user.save();

    console.log(`Email updated successfully from ${oldEmail} to ${newEmail}`);
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

updateAdminEmail();
