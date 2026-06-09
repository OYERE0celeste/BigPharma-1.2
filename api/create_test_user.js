/**
 * Script pour créer un utilisateur de test
 */
require('./config/loadEnv');
const User = require('./models/User');
const Company = require('./models/Company');
const mongoose = require('mongoose');

async function createTestUser() {
  try {
    // Connexion à MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connecté à MongoDB');

    // Récupérer ou créer une company
    let company = await Company.findOne({ email: 'contact@bigpharma.com' });
    if (!company) {
      company = await Company.create({
        name: 'BigPharma HQ',
        email: 'contact@bigpharma.com',
        phone: '22900000000',
        address: 'Avenue de la Santé, Cotonou',
      });
      console.log('✓ Company créée');
    }

    // Créer l'utilisateur de test
    const testUser = await User.create({
      fullName: 'Test User',
      email: 'test@example.com',
      passwordHash: 'TestPassword123!', // Sera hashé par le pre-save hook
      role: 'pharmacien',
      companyId: company._id,
      isActive: true,
    });

    console.log('✓ Utilisateur de test créé avec succès!');
    console.log('\n📋 Identifiants de test:');
    console.log('  Email: test@example.com');
    console.log('  Mot de passe: TestPassword123!');
    console.log('\n✓ Vous pouvez maintenant utiliser ces identifiants pour tester l\'API');

    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    process.exit(1);
  }
}

createTestUser();
