const mongoose = require('mongoose');
const Order = require('./api/models/order');
require('dotenv').config();

const migrate = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bigpharma');
    console.log('Connected to database');

    // Orders in 'en_preparation' or 'en_livraison' -> 'annulee' (as per user request "remplaces par annulé")
    const result1 = await Order.updateMany(
      { status: { $in: ['en_preparation', 'en_livraison'] } },
      { $set: { status: 'annulee' } }
    );
    console.log(`Migrated ${result1.modifiedCount} preparation/delivery orders to annulee`);

    // Orders in 'livree' -> 'validee' (since 'validee' is the final success state now)
    const result2 = await Order.updateMany(
      { status: 'livree' },
      { $set: { status: 'validee' } }
    );
    console.log(`Migrated ${result2.modifiedCount} livree orders to validee`);

    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
};

migrate();
