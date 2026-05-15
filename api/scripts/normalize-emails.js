const mongoose = require("mongoose");
const path = require("path");
const User = require("../models/User");
const Client = require("../models/client");
require("dotenv").config({ path: path.join(__dirname, "../.env") });

async function normalizeEmails() {
  try {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/BigPharmaDB";
    await mongoose.connect(uri);
    console.log("✓ Connected to MongoDB");

    // Normalize User emails
    const users = await User.find({});
    console.log(`Found ${users.length} users to check`);

    let usersDuplicates = 0;
    for (const user of users) {
      if (user.email) {
        const normalized = user.email.toLowerCase().trim();
        if (user.email !== normalized) {
          user.email = normalized;
          await user.save();
          console.log(`✓ Normalized user ${user._id}: "${user.email}" -> "${normalized}"`);
        }
      }
    }

    // Remove duplicate emails - keep first, delete rest
    const usersByEmail = {};
    const usersToDelete = [];

    for (const user of users) {
      const email = (user.email || "").toLowerCase().trim();
      if (email) {
        if (usersByEmail[email]) {
          console.warn(`⚠ Duplicate email found: ${email} (keeping ${usersByEmail[email]}, deleting ${user._id})`);
          usersToDelete.push(user._id);
        } else {
          usersByEmail[email] = user._id;
        }
      }
    }

    if (usersToDelete.length > 0) {
      console.log(`\n⚠ WARNING: Found ${usersToDelete.length} duplicate users. Review before deletion!`);
      for (const id of usersToDelete) {
        const dupUser = await User.findById(id);
        console.log(`  - ${dupUser.email} (${id}) by ${dupUser.fullName}`);
      }
    }

    // Normalize Client emails
    const clients = await Client.find({});
    console.log(`\n✓ Found ${clients.length} clients to check`);

    for (const client of clients) {
      if (client.email) {
        const normalized = client.email.toLowerCase().trim();
        if (client.email !== normalized) {
          client.email = normalized;
          await client.save();
          console.log(`✓ Normalized client ${client._id}: "${normalized}"`);
        }
      }
    }

    console.log("\n✅ Email normalization complete!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
}

normalizeEmails();
