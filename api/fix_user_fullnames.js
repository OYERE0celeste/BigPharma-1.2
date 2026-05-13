const mongoose = require("mongoose");
const User = require("./models/User");
require("dotenv").config();

const fixUserFullNames = async () => {
  try {
    const dbUri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    console.log(`Connecting to ${dbUri}...`);
    await mongoose.connect(dbUri);
    console.log("Connected to database\n");

    // 1. Find all users with problematic fullNames
    const users = await User.find();
    console.log(`Found ${users.length} users total\n`);

    // 2. Show current users
    console.log("=== CURRENT USERS ===");
    users.forEach(user => {
      console.log(`Email: ${user.email} | FullName: "${user.fullName}" | Role: ${user.role}`);
    });
    console.log();

    // 3. Fix: If fullName is "Administrateur Système" and email is lafloral@gmail.com,
    // generate a proper name from email
    const result = await User.updateMany(
      { 
        fullName: "Administrateur Système",
        email: "lafloral@gmail.com"
      },
      { 
        $set: { 
          fullName: "La Floral" // Extract from email or provide proper name
        } 
      }
    );

    console.log(`✓ Fixed ${result.modifiedCount} user(s) with incorrect fullName\n`);

    // 4. Show updated users
    const updatedUsers = await User.find();
    console.log("=== UPDATED USERS ===");
    updatedUsers.forEach(user => {
      console.log(`Email: ${user.email} | FullName: "${user.fullName}" | Role: ${user.role}`);
    });

    console.log("\n✓ Migration completed successfully");
    process.exit(0);
  } catch (error) {
    console.error("Migration failed:", error);
    process.exit(1);
  }
};

fixUserFullNames();
