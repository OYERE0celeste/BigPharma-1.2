/**
 * Suite de test API complète
 * Teste tous les endpoints critiques
 */
const http = require('http');

const API_URL = 'http://localhost:5000/api';
let accessToken = '';

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(accessToken && { 'Authorization': `Bearer ${accessToken}` }),
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            body: JSON.parse(data),
            headers: res.headers,
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            body: data,
            headers: res.headers,
          });
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Suite de tests API - BigPharma\n');
  console.log('=' .repeat(60));

  let passed = 0;
  let failed = 0;

  // Test 1: Health Check
  console.log('\n📋 Test 1: Health Check');
  try {
    const res = await makeRequest('GET', '/health');
    if (res.status === 200 && res.body.data.status === 'healthy') {
      console.log('✅ PASS: Serveur healthy');
      passed++;
    } else {
      console.log('❌ FAIL: Health check failed');
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 2: Login
  console.log('\n📋 Test 2: Login (test@example.com)');
  try {
    const res = await makeRequest('POST', '/auth/login', {
      email: 'test@example.com',
      password: 'TestPassword123!',
    });
    if (res.status === 200 && res.body.data.accessToken) {
      accessToken = res.body.data.accessToken;
      console.log('✅ PASS: Login successful, token obtained');
      console.log(`   Token: ${accessToken.substring(0, 30)}...`);
      console.log(`   Role: ${res.body.data.user.role}`);
      passed++;
    } else {
      console.log('❌ FAIL: Login failed');
      console.log('   Response:', res.body);
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 3: Get Products
  console.log('\n📋 Test 3: Get Products');
  try {
    const res = await makeRequest('GET', '/products?page=1&limit=10');
    if (res.status === 200 && Array.isArray(res.body.data)) {
      console.log(`✅ PASS: Retrieved ${res.body.data.length} products`);
      if (res.body.data.length > 0) {
        const firstProduct = res.body.data[0];
        console.log(`   First product: ${firstProduct.name} (${firstProduct.barcode})`);
      }
      passed++;
    } else {
      console.log('❌ FAIL: Could not retrieve products');
      console.log('   Response:', res.body);
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 4: Get Clients
  console.log('\n📋 Test 4: Get Clients');
  try {
    const res = await makeRequest('GET', '/clients?page=1&limit=10');
    if (res.status === 200) {
      console.log(`✅ PASS: Retrieved clients data`);
      console.log(`   Total: ${res.body.data.length || res.body.total || '?'}`);
      passed++;
    } else {
      console.log('❌ FAIL: Could not retrieve clients');
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 5: Get Sales
  console.log('\n📋 Test 5: Get Sales');
  try {
    const res = await makeRequest('GET', '/sales?page=1&limit=10');
    if (res.status === 200) {
      console.log(`✅ PASS: Retrieved sales data`);
      console.log(`   Total: ${res.body.data.length || res.body.total || '?'}`);
      passed++;
    } else {
      console.log('❌ FAIL: Could not retrieve sales');
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 6: Get Orders
  console.log('\n📋 Test 6: Get Orders');
  try {
    const res = await makeRequest('GET', '/orders?page=1&limit=10');
    if (res.status === 200) {
      console.log(`✅ PASS: Retrieved orders data`);
      console.log(`   Total: ${res.body.data.length || res.body.total || '?'}`);
      passed++;
    } else {
      console.log('❌ FAIL: Could not retrieve orders');
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Test 7: Create Client
  console.log('\n📋 Test 7: Create Client');
  try {
    const res = await makeRequest('POST', '/clients', {
      fullName: 'Test Client',
      email: `client-${Date.now()}@example.com`,
      phone: '1234567890',
      address: 'Test Address',
    });
    if (res.status === 201 || res.status === 200) {
      console.log('✅ PASS: Client created successfully');
      console.log(`   Client ID: ${res.body.data._id || res.body.data.id}`);
      passed++;
    } else {
      console.log('❌ FAIL: Could not create client');
      console.log('   Response:', res.body);
      failed++;
    }
  } catch (e) {
    console.log('❌ FAIL:', e.message);
    failed++;
  }

  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('\n📊 RÉSULTATS:');
  console.log(`   ✅ Passé: ${passed}`);
  console.log(`   ❌ Échoué: ${failed}`);
  console.log(`   📈 Total: ${passed + failed}`);
  console.log(`   🎯 Succès: ${((passed / (passed + failed)) * 100).toFixed(1)}%`);
  console.log('\n' + '='.repeat(60));

  process.exit(failed > 0 ? 1 : 0);
}

runTests().catch(e => {
  console.error('Erreur fatale:', e);
  process.exit(1);
});
