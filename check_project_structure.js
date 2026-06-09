#!/usr/bin/env node

/**
 * Script de vérification complète - BigPharma Applications
 * Vérifie les configurations, dépendances et fichiers critiques
 */

const fs = require('fs');
const path = require('path');

const PROJECT_ROOT = 'd:\\Projets\\BigPharma 1.2';
const APPS = {
  'client_app': path.join(PROJECT_ROOT, 'client_app'),
  'epharma': path.join(PROJECT_ROOT, 'epharma'),
  'api': path.join(PROJECT_ROOT, 'api'),
};

let passed = 0;
let failed = 0;
let warnings = 0;

function checkFile(appName, filePath, description) {
  const fullPath = path.join(APPS[appName], filePath);
  const exists = fs.existsSync(fullPath);
  
  if (exists) {
    console.log(`  ✅ ${description}`);
    passed++;
  } else {
    console.log(`  ❌ ${description} - NOT FOUND`);
    failed++;
  }
  
  return exists;
}

function checkFileContent(appName, filePath, searchString, description) {
  const fullPath = path.join(APPS[appName], filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`  ❌ ${description} - File not found`);
    failed++;
    return false;
  }
  
  const content = fs.readFileSync(fullPath, 'utf-8');
  const found = content.includes(searchString);
  
  if (found) {
    console.log(`  ✅ ${description}`);
    passed++;
  } else {
    console.log(`  ⚠️  ${description} - Content not found`);
    warnings++;
  }
  
  return found;
}

console.log('🔍 Vérification complète - BigPharma Applications\n');
console.log('='.repeat(70) + '\n');

// ============ API CHECKS ============
console.log('📦 API SERVER CHECKS');
console.log('-'.repeat(70));

checkFile('api', '.env', 'Configuration .env');
checkFile('api', 'package.json', 'Package.json');
checkFile('api', 'server.js', 'Serveur principal');
checkFile('api', 'models/User.js', 'Modèle User');
checkFile('api', 'models/product.js', 'Modèle Product');
checkFile('api', 'routes/', 'Répertoire routes');
checkFileContent('api', 'package.json', '"express"', 'Dépendance Express');
checkFileContent('api', 'package.json', '"mongoose"', 'Dépendance MongoDB');
checkFileContent('api', 'package.json', '"jsonwebtoken"', 'Dépendance JWT');

console.log('\n📱 CLIENT_APP CHECKS');
console.log('-'.repeat(70));

checkFile('client_app', 'pubspec.yaml', 'Pubspec.yaml');
checkFile('client_app', 'lib/main.dart', 'Main.dart');
checkFile('client_app', 'lib/services/api_constants.dart', 'API Constants');
checkFile('client_app', 'lib/providers/auth_provider.dart', 'Auth Provider');
checkFile('client_app', 'lib/ventes/pharmacy_sales_page.dart', 'Sales Page');
checkFile('client_app', 'lib/scanner/providers/scanner_provider.dart', 'Scanner Provider');
checkFile('client_app', 'lib/scanner/dialogs/scanner_dialog.dart', 'Scanner Dialog');
checkFileContent('client_app', 'pubspec.yaml', 'provider:', 'Dépendance Provider');
checkFileContent('client_app', 'pubspec.yaml', 'mobile_scanner:', 'Dépendance Mobile Scanner');
checkFileContent('client_app', 'lib/main.dart', 'MultiProvider', 'Setup MultiProvider');

console.log('\n📱 EPHARMA CHECKS');
console.log('-'.repeat(70));

checkFile('epharma', 'pubspec.yaml', 'Pubspec.yaml');
checkFile('epharma', 'lib/main.dart', 'Main.dart');
checkFile('epharma', 'lib/services/api_constants.dart', 'API Constants');
checkFile('epharma', 'lib/providers/auth_provider.dart', 'Auth Provider');
checkFile('epharma', 'lib/ventes/pharmacy_sales_page.dart', 'Sales Page');
checkFile('epharma', 'lib/scanner/providers/scanner_provider.dart', 'Scanner Provider');
checkFileContent('epharma', 'pubspec.yaml', 'provider:', 'Dépendance Provider');
checkFileContent('epharma', 'lib/main.dart', 'MultiProvider', 'Setup MultiProvider');

console.log('\n🔧 SCANNER SYSTEM CHECKS (epharma)');
console.log('-'.repeat(70));

checkFile('epharma', 'lib/scanner/services/global_keyboard_scanner_service.dart', 'Global Scanner Service');
checkFile('epharma', 'lib/scanner/services/barcode_detection_engine.dart', 'Barcode Detection');
checkFile('epharma', 'lib/scanner/widgets/global_scanner_listener.dart', 'Global Listener Widget');
checkFile('epharma', 'lib/scanner/services/scanner_event_bus.dart', 'Event Bus Service');
checkFile('epharma', 'lib/scanner/dialogs/product_not_found_dialog.dart', 'Product Not Found Dialog');

console.log('\n📋 CRITICAL PATHS CHECK');
console.log('-'.repeat(70));

// Check if main API endpoints exist
const apiRoutesPath = path.join(APPS['api'], 'routes');
const apiRoutes = fs.existsSync(apiRoutesPath) 
  ? fs.readdirSync(apiRoutesPath).filter(f => f.endsWith('.js'))
  : [];

console.log(`  API Routes found: ${apiRoutes.length}`);
if (apiRoutes.length > 0) {
  console.log(`  ✅ ${apiRoutes.join(', ')}`);
  passed++;
} else {
  console.log(`  ❌ No API routes found`);
  failed++;
}

// Check Flutter projects structure
const clientAppLibPath = path.join(APPS['client_app'], 'lib');
const epharmaLibPath = path.join(APPS['epharma'], 'lib');

const clientDirs = fs.existsSync(clientAppLibPath) 
  ? fs.readdirSync(clientAppLibPath).filter(f => {
      const stat = fs.statSync(path.join(clientAppLibPath, f));
      return stat.isDirectory();
    })
  : [];

const epharmaDir = fs.existsSync(epharmaLibPath) 
  ? fs.readdirSync(epharmaLibPath).filter(f => {
      const stat = fs.statSync(path.join(epharmaLibPath, f));
      return stat.isDirectory();
    })
  : [];

console.log(`\n  client_app lib directories: ${clientDirs.length}`);
if (clientDirs.includes('providers') && clientDirs.includes('services')) {
  console.log(`  ✅ Essential directories present`);
  passed++;
} else {
  console.log(`  ❌ Missing essential directories`);
  failed++;
}

console.log(`\n  epharma lib directories: ${epharmaDir.length}`);
if (epharmaDir.includes('providers') && epharmaDir.includes('services')) {
  console.log(`  ✅ Essential directories present`);
  passed++;
} else {
  console.log(`  ❌ Missing essential directories`);
  failed++;
}

// Summary
console.log('\n' + '='.repeat(70));
console.log('\n📊 RÉSULTATS VÉRIFICATION:');
console.log(`   ✅ Passé: ${passed}`);
console.log(`   ❌ Échoué: ${failed}`);
console.log(`   ⚠️  Avertissement: ${warnings}`);
console.log(`   📈 Total: ${passed + failed + warnings}`);
console.log(`   🎯 Santé: ${((passed / (passed + failed + warnings)) * 100).toFixed(1)}%`);

if (failed === 0) {
  console.log('\n✨ Toutes les vérifications structurelles sont passées!');
} else {
  console.log('\n❌ Certains fichiers critiques manquent!');
}

console.log('\n' + '='.repeat(70) + '\n');

process.exit(failed > 0 ? 1 : 0);
