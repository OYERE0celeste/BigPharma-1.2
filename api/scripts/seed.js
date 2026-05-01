const mongoose = require('mongoose');
const User = require('../models/user');
const Company = require('../models/company');
const Product = require('../models/product');
require('dotenv').config();

const seedDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB for seeding...');

    // Clear existing data
    await User.deleteMany({});
    await Company.deleteMany({});
    await Product.deleteMany({});

    // 1. Create a Company
    const company = await Company.create({
      name: 'Pharmacie Centrale',
      email: 'contact@centrale.com',
      phone: '+225 01010101',
      address: 'Abidjan, Plateau',
      status: 'active'
    });

    // 2. Create Users
    await User.create([
      {
        fullName: 'Admin Pharmacie',
        email: 'admin@centrale.com',
        password: 'password123', // Will be hashed by pre-save hook
        role: 'admin',
        companyId: company._id
      },
      {
        fullName: 'Staff Pharmacie',
        email: 'staff@centrale.com',
        password: 'password123',
        role: 'staff',
        companyId: company._id
      }
    ]);

    // 3. Create Products
    await Product.create([
      {
        name: 'Aspirine 500mg',
        sellingPrice: 1200,
        category: 'Analgésique',
        stockQuantity: 100,
        companyId: company._id,
        description: 'Pour les maux de tête et la fièvre.'
      },
      {
        name: 'Amoxicilline 1g',
        sellingPrice: 3500,
        category: 'Antibiotique',
        stockQuantity: 50,
        companyId: company._id,
        prescriptionRequired: true
      }
    ]);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
