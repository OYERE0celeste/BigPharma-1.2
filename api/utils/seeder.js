const User = require("../models/User");
const Company = require("../models/Company");
const Product = require("../models/product");
const logger = require("./logger");

/**
 * Seeds a default administrator and company if none exist.
 */
async function seedAdmin() {
  try {
    // 1. Ensure a default company exists
    let company = await Company.findOne({ email: "contact@bigpharma.com" });
    if (!company) {
      company = await Company.create({
        name: "BigPharma HQ",
        email: "contact@bigpharma.com",
        phone: "22900000000",
        address: "Avenue de la Santé, Cotonou",
        city: "Cotonou",
        country: "Bénin",
      });
      logger.info("[SEED] Default company created.");
    }

    // 2. Ensure a default admin exists only when the system has no admin yet.
    // This avoids recreating the seeded account after an admin changes email.
    const adminEmail = "laflorale8@gmail.com";
    const adminExists = await User.exists({
      role: { $in: ["administrateur", "admin"] },
    });
    
    if (!adminExists) {
      await User.create({
        fullName: "Administrateur Système",
        email: adminEmail,
        passwordHash: "administrateur", // Will be hashed by pre-save hook
        role: "administrateur",
        companyId: company._id,
        isActive: true,
      });
      logger.info(`[SEED] Default administrator created: ${adminEmail} / admin`);
    }

    // 3. Ensure parapharmacy seed products exist
    const productCount = await Product.countDocuments();
    if (productCount === 0) {
      logger.info("[SEED] Seeding realistic parapharmacy products...");
      const productsData = [
        // 1. Dermo-cosmétique (Soins du visage)
        {
          name: "Eau Thermale Avène - Spray 300ml",
          category: "Dermo-cosmétique (Soins du visage)",
          description: "Apaisante et anti-irritante pour peaux sensibles.",
          barcode: "3282779080000",
          purchasePrice: 5000,
          sellingPrice: 7500,
          lowStockThreshold: 15,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "AV8001", quantity: 60, quantityAvailable: 60, costPrice: 5000, expirationDate: new Date("2028-06-30") },
            { lotNumber: "AV8002", quantity: 20, quantityAvailable: 20, costPrice: 5000, expirationDate: new Date("2026-06-30") }, // Proche expiration
          ]
        },
        {
          name: "La Roche-Posay Effaclar Duo+ 40ml",
          category: "Dermo-cosmétique (Soins du visage)",
          description: "Soin complet anti-imperfections, désincrustant et anti-marques.",
          barcode: "3337872414000",
          purchasePrice: 7000,
          sellingPrice: 9800,
          lowStockThreshold: 10,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "LR4001", quantity: 45, quantityAvailable: 45, costPrice: 7000, expirationDate: new Date("2027-12-31") }
          ]
        },
        {
          name: "CeraVe Crème Hydratante 454g",
          category: "Dermo-cosmétique (Soins du visage)",
          description: "Nourrit, hydrate et restaure la barrière protectrice de la peau.",
          barcode: "3337875597300",
          purchasePrice: 8000,
          sellingPrice: 11500,
          lowStockThreshold: 12,
          minStockLevel: 8,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "CV7300", quantity: 50, quantityAvailable: 50, costPrice: 8000, expirationDate: new Date("2028-09-30") }
          ]
        },
        // 2. Hygiène Corporelle
        {
          name: "Bioderma Atoderm Huile de Douche 1L",
          category: "Hygiène Corporelle",
          description: "Huile de douche ultra-nourrissante et anti-irritations pour peaux sèches.",
          barcode: "3401560936900",
          purchasePrice: 6500,
          sellingPrice: 9200,
          lowStockThreshold: 15,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "BD3690", quantity: 80, quantityAvailable: 80, costPrice: 6500, expirationDate: new Date("2028-03-31") }
          ]
        },
        {
          name: "Rogé Cavaillès Gel Bain Douche 400ml",
          category: "Hygiène Corporelle",
          description: "Nettoie en douceur et nourrit intensément les peaux sensibles de toute la famille.",
          barcode: "3020030040000",
          purchasePrice: 4000,
          sellingPrice: 5800,
          lowStockThreshold: 20,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "RC4000", quantity: 100, quantityAvailable: 100, costPrice: 4000, expirationDate: new Date("2027-10-31") }
          ]
        },
        // 3. Soins Capillaires
        {
          name: "Klorane Shampooing à la Quinine 400ml",
          category: "Soins Capillaires",
          description: "Fortifiant et stimulant pour cheveux fatigués ou en cas de chute de cheveux.",
          barcode: "3282770140800",
          purchasePrice: 4500,
          sellingPrice: 6300,
          lowStockThreshold: 10,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "KL4080", quantity: 35, quantityAvailable: 35, costPrice: 4500, expirationDate: new Date("2027-08-31") }
          ]
        },
        {
          name: "Ducray Anaphase+ Shampooing 200ml",
          category: "Soins Capillaires",
          description: "Complément idéal des traitements antichute. Apporte volume et vigueur.",
          barcode: "3282770075500",
          purchasePrice: 5500,
          sellingPrice: 7800,
          lowStockThreshold: 10,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "DC7550", quantity: 40, quantityAvailable: 40, costPrice: 5500, expirationDate: new Date("2027-05-31") }
          ]
        },
        // 4. Santé Bucco-dentaire
        {
          name: "Elmex Dentifrice Anti-Caries Duo",
          category: "Santé Bucco-dentaire",
          description: "Protège efficacement les dents contre les caries grâce au fluorure d'amine Olaflur.",
          barcode: "7610108055600",
          purchasePrice: 2500,
          sellingPrice: 3800,
          lowStockThreshold: 20,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "EL5560", quantity: 120, quantityAvailable: 120, costPrice: 2500, expirationDate: new Date("2028-11-30") }
          ]
        },
        {
          name: "Sensodyne Traitement Sensibilité 75ml",
          category: "Santé Bucco-dentaire",
          description: "Soulagement cliniquement prouvé de la sensibilité dentaire.",
          barcode: "5011417562100",
          purchasePrice: 2200,
          sellingPrice: 3400,
          lowStockThreshold: 20,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "SS6210", quantity: 90, quantityAvailable: 90, costPrice: 2200, expirationDate: new Date("2028-04-30") }
          ]
        },
        // 5. Maternité et Bébé
        {
          name: "Lait Bébé Guigoz Optipro 1er Âge 800g",
          category: "Maternité et Bébé",
          description: "Lait en poudre pour nourrissons de la naissance jusqu'à 6 mois.",
          barcode: "7613035128700",
          purchasePrice: 7500,
          sellingPrice: 10500,
          lowStockThreshold: 15,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "GG1287", quantity: 50, quantityAvailable: 50, costPrice: 7500, expirationDate: new Date("2027-02-28") }
          ]
        },
        {
          name: "Mustela Crème Change 123 100ml",
          category: "Maternité et Bébé",
          description: "Prévient, apaise et répare les rougeurs du siège dès la naissance.",
          barcode: "3504105025800",
          purchasePrice: 3200,
          sellingPrice: 4800,
          lowStockThreshold: 25,
          minStockLevel: 10,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "MS2580", quantity: 110, quantityAvailable: 110, costPrice: 3200, expirationDate: new Date("2028-01-31") }
          ]
        },
        // 6. Compléments Alimentaires et Vitamines
        {
          name: "Vitamine C UPSA 1000mg Effervescent",
          category: "Compléments Alimentaires et Vitamines",
          description: "Aide à réduire la fatigue et soutient le système immunitaire.",
          barcode: "3400933454800",
          purchasePrice: 1500,
          sellingPrice: 2500,
          lowStockThreshold: 30,
          minStockLevel: 15,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "UP5480", quantity: 200, quantityAvailable: 200, costPrice: 1500, expirationDate: new Date("2027-09-30") }
          ]
        },
        {
          name: "Bion 3 Défense 60 Comprimés",
          category: "Compléments Alimentaires et Vitamines",
          description: "Formule complète avec 3 ferments brevetés, 12 vitamines et 7 minéraux.",
          barcode: "3401143890800",
          purchasePrice: 9000,
          sellingPrice: 13500,
          lowStockThreshold: 10,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "BI9080", quantity: 60, quantityAvailable: 60, costPrice: 9000, expirationDate: new Date("2027-11-30") }
          ]
        },
        // 7. Premiers Secours et Bobologie
        {
          name: "Mercurochrome Compresses Stériles x50",
          category: "Premiers Secours et Bobologie",
          description: "Compresses de gaze hydrophile pour le nettoyage et la couverture des plaies.",
          barcode: "3160920500300",
          purchasePrice: 1800,
          sellingPrice: 2800,
          lowStockThreshold: 15,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "MC0030", quantity: 150, quantityAvailable: 150, costPrice: 1800, expirationDate: new Date("2029-12-31") }
          ]
        },
        // 8. Protection Solaire
        {
          name: "La Roche-Posay Anthelios UVMune 400 SPF50+",
          category: "Protection Solaire",
          description: "Fluide invisible très haute protection solaire pour le visage.",
          barcode: "3337875797400",
          purchasePrice: 8500,
          sellingPrice: 12000,
          lowStockThreshold: 12,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "AT9740", quantity: 70, quantityAvailable: 70, costPrice: 8500, expirationDate: new Date("2028-06-30") }
          ]
        },
        {
          name: "Avène Fluide Solaire SPF50+ Sans Parfum",
          category: "Protection Solaire",
          description: "Protection solaire visage très large spectre UVB-UVA et lumière bleue.",
          barcode: "3282770144900",
          purchasePrice: 8000,
          sellingPrice: 11500,
          lowStockThreshold: 10,
          minStockLevel: 5,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "AV4490", quantity: 50, quantityAvailable: 50, costPrice: 8000, expirationDate: new Date("2028-04-30") }
          ]
        },
        // 9. Diététique et Phytothérapie
        {
          name: "Arkopharma Arkogélules Charbon Végétal x45",
          category: "Diététique et Phytothérapie",
          description: "Complément alimentaire pour le confort digestif et contre les ballonnements.",
          barcode: "3401173874900",
          purchasePrice: 3500,
          sellingPrice: 5200,
          lowStockThreshold: 15,
          minStockLevel: 8,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "AK7490", quantity: 95, quantityAvailable: 95, costPrice: 3500, expirationDate: new Date("2027-10-31") }
          ]
        },
        // 10. Orthopédie et Contention Légère
        {
          name: "Thuasne Genouillère Élastique Sport",
          category: "Orthopédie et Contention Légère",
          description: "Maintien souple de l'articulation fragilisée ou douloureuse.",
          barcode: "3111600104200",
          purchasePrice: 12000,
          sellingPrice: 18000,
          lowStockThreshold: 5,
          minStockLevel: 3,
          expirationAlertThreshold: 90,
          isActive: true,
          companyId: company._id,
          lots: [
            { lotNumber: "TH1042", quantity: 20, quantityAvailable: 20, costPrice: 12000, expirationDate: new Date("2030-12-31") }
          ]
        }
      ];

      const seededProducts = await Product.create(productsData);
      logger.info(`[SEED] ${seededProducts.length} parapharmacy products successfully seeded.`);

      // Link generic mutual substitutions
      logger.info("[SEED] Linking mutual product substitutions...");
      const aveneSolaire = seededProducts.find(p => p.barcode === "3282770144900");
      const lrpSolaire = seededProducts.find(p => p.barcode === "3337875797400");
      if (aveneSolaire && lrpSolaire) {
        aveneSolaire.substitutes.push(lrpSolaire._id);
        lrpSolaire.substitutes.push(aveneSolaire._id);
        await aveneSolaire.save();
        await lrpSolaire.save();
      }

      const aveneSpray = seededProducts.find(p => p.barcode === "3282779080000");
      const lrpEffaclar = seededProducts.find(p => p.barcode === "3337872414000");
      if (aveneSpray && lrpEffaclar) {
        aveneSpray.substitutes.push(lrpEffaclar._id);
        lrpEffaclar.substitutes.push(aveneSpray._id);
        await aveneSpray.save();
        await lrpEffaclar.save();
      }

      const elmex = seededProducts.find(p => p.barcode === "7610108055600");
      const sensodyne = seededProducts.find(p => p.barcode === "5011417562100");
      if (elmex && sensodyne) {
        elmex.substitutes.push(sensodyne._id);
        sensodyne.substitutes.push(elmex._id);
        await elmex.save();
        await sensodyne.save();
      }
      logger.info("[SEED] Mutual product substitutions linked successfully.");
    }
  } catch (error) {
    logger.error("[SEED] Error seeding default admin & products:", error);
  }
}

module.exports = { seedAdmin };
