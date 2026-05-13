const mongoose = require("mongoose");
const User = require("./models/User");
require("dotenv").config();

const fixInvalidRoles = async () => {
  try {
    const dbUri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    console.log(`Connecting to ${dbUri}...`);
    await mongoose.connect(dbUri);
    console.log("Connected to database\n");

    // Valid roles according to User.js model
    const validRoles = [
      "administrateur",
      "pharmacien",
      "caissier",
      "gestionnaire de stock",
      "assistante de gestion",
      "client",
    ];

    // 1. Find all users
    const allUsers = await User.find();
    console.log(`Found ${allUsers.length} users total\n`);

    // 2. Check for invalid roles
    const invalidUsers = allUsers.filter(u => !validRoles.includes(u.role));
    
    if (invalidUsers.length > 0) {
      console.log(`⚠️  Found ${invalidUsers.length} user(s) with invalid roles:\n`);
      invalidUsers.forEach(user => {
        console.log(`  - Email: ${user.email} | Role: "${user.role}" (INVALID)`);
      });
      console.log();

      // 3. Fix invalid roles - convert to default "pharmacien"
      const fixResult = await User.updateMany(
        { role: { $nin: validRoles } },
        { $set: { role: "pharmacien" } }
      );

      console.log(`✓ Fixed ${fixResult.modifiedCount} user(s) with invalid roles\n`);
    } else {
      console.log("✓ All users have valid roles\n");
    }

    // 4. Show all roles in use
    const roleStats = {};
    allUsers.forEach(user => {
      roleStats[user.role] = (roleStats[user.role] || 0) + 1;
    });

    console.log("=== ROLE STATISTICS ===");
    Object.entries(roleStats).forEach(([role, count]) => {
      const isValid = validRoles.includes(role);
      const status = isValid ? "✓" : "✗";
      console.log(`${status} ${role}: ${count} user(s)`);
    });

    console.log("\n✓ Validation completed successfully");
    process.exit(0);
  } catch (error) {
    console.error("Validation failed:", error);
    process.exit(1);
  }
};

fixInvalidRoles();
