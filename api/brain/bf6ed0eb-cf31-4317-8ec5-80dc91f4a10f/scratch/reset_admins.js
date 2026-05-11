const mongoose = require("mongoose");
const User = require("../../../models/User");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function resetAllAdminPasswords() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    
    const newPassword = "laflorale123";
    const admins = await User.find({ role: { $in: ["administrateur", "admin"] } });
    
    for (const admin of admins) {
      admin.passwordHash = newPassword;
      await admin.save();
      console.log(`Password updated for ${admin.email} (${admin.role})`);
    }

    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

resetAllAdminPasswords();
