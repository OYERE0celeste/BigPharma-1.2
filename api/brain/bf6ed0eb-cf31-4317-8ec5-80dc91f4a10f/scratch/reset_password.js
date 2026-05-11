const mongoose = require("mongoose");
const User = require("../../../models/User");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../../../.env") });

async function resetPassword() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    console.log("Connecting to:", uri);
    await mongoose.connect(uri);
    console.log("Connected to DB");

    const email = "admin@pharmacie.com";
    const newPassword = "laflorale123";

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      console.error(`User ${email} not found`);
      // Try finding any user with role 'administrateur'
      const anyAdmin = await User.findOne({ role: { $in: ["administrateur", "admin"] } });
      if (anyAdmin) {
        console.log(`Found another admin: ${anyAdmin.email}`);
        anyAdmin.passwordHash = newPassword;
        await anyAdmin.save();
        console.log(`Password updated successfully for ${anyAdmin.email}`);
      } else {
        process.exit(1);
      }
    } else {
      user.passwordHash = newPassword;
      await user.save();
      console.log(`Password updated successfully for ${email}`);
    }

    process.exit(0);
  } catch (error) {
    console.error("Error updating password:", error);
    process.exit(1);
  }
}

resetPassword();
