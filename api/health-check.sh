#!/bin/bash
# API Health Check Script

echo "🏥 BigPharma API Health Check"
echo "================================"

API_URL="http://localhost:5000/api"

echo ""
echo "1. Checking API Health..."
curl -s "$API_URL/health" | jq . || echo "❌ API is not responding"

echo ""
echo "2. Testing without auth (should work)..."
curl -s "$API_URL/products?limit=1" | jq '.success' || echo "❌ Products endpoint failed"

echo ""
echo "3. Testing with invalid token (should fail with 401)..."
curl -s -H "Authorization: Bearer invalid_token" "$API_URL/auth/me" | jq '.code' || echo "❌ Auth test failed"

echo ""
echo "================================"
echo "✅ Health check complete!"
echo ""
echo "To run full tests: npm test"
echo "To start server: npm run dev"
