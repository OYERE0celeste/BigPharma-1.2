require('dotenv').config({ path: __dirname + '/../.env' });
const mongoose = require('mongoose');

async function fixRoles() {
  if (!process.env.MONGODB_URI) {
    console.error("No MONGODB_URI found");
    process.exit(1);
  }

  await mongoose.connect(process.env.MONGODB_URI);
  console.log("Connected to MongoDB");

  const usersCollection = mongoose.connection.collection('users');
  
  // Fix 'admin' -> 'administrateur'
  const adminResult = await usersCollection.updateMany(
    { role: 'admin' },
    { $set: { role: 'administrateur' } }
  );
  console.log(`Fixed ${adminResult.modifiedCount} users with role 'admin'`);

  // Log invalid roles
  const validRoles = ["administrateur", "pharmacien", "caissier", "gestionnaire de stock", "assistante de gestion", "client"];
  const invalidRoles = await usersCollection.distinct("role", { role: { $nin: validRoles } });
  
  console.log("Invalid roles still present:", invalidRoles);

  if (invalidRoles.includes("cashier")) {
    const res = await usersCollection.updateMany({ role: 'cashier' }, { $set: { role: 'caissier' }});
    console.log(`Fixed ${res.modifiedCount} users with role 'cashier'`);
  }

  console.log("Done");
  process.exit(0);
}

fixRoles().catch(err => {
  console.error(err);
  process.exit(1);
});
