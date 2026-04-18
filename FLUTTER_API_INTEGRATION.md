# Flutter Apps Integration with BigPharma API

## Overview

Both `client_app` and `epharma` Flutter applications are designed to work with the BigPharma API server. This guide explains how they interact and how to set them up correctly.

## Architecture

```
┌─────────────────┐
│   client_app    │ (Customer mobile app)
│   (Flutter)     │
└────────┬────────┘
         │
         │ HTTP Requests
         │
         ▼
┌─────────────────────────────┐
│   BigPharma API (Node.js)   │
│   mongodb://localhost...    │
└─────────────────────────────┘
         ▲
         │ HTTP Requests
         │
         ├────────────────┐
         │                │
┌────────┴────────┐  ┌───┴──────────┐
│   epharma       │  │   MongoDB    │
│   (Flutter Web) │  │              │
└─────────────────┘  └──────────────┘
```

## client_app Configuration

### Purpose
Customer-facing mobile application for:
- Browsing products
- Registering and managing profile
- Creating and tracking orders
- Viewing prescriptions

### API Base URL Detection

The app automatically determines the API URL based on platform:

**In `lib/services/api_constants.dart`:**
```dart
static String get baseUrl {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

  if (kIsWeb) {
    if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
      return 'http://localhost:5000/api';
    }
    return '${Uri.base.origin}/api';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000/api';
  }

  return 'http://localhost:5000/api';
}
```

### Running client_app

**For Android Emulator:**
```bash
cd client_app
flutter pub get
flutter run
```

The emulator will connect to `http://10.0.2.2:5000/api`

**For Android Physical Device:**
1. Update `api_constants.dart` with your machine IP:
   ```dart
   return 'http://192.168.x.x:5000/api';
   ```
2. Ensure API server is accessible from device network
3. Add device network IP to API CORS_ORIGIN

**For iOS:**
```bash
cd client_app
flutter run -d ios
```

**For Web:**
```bash
cd client_app
flutter run -d web
```

Access at `http://localhost:5000/api`

### Key Services

**auth_service.dart**
- `login()`: Authenticate user
- `registerClient()`: Create new client account

**product_service.dart**
- `getPopularProducts()`: Get featured products
- `getNewProducts()`: Get latest products
- `getProductDetails()`: Get single product

**order_service.dart**
- `createOrder()`: Place new order
- `getMyOrders()`: Retrieve user's orders

**profile_provider.dart**
- `getMe()`: Get user profile
- `updateProfile()`: Update user information

### Authentication Flow

1. User registers via `/api/auth/register-client`
2. Token saved to SharedPreferences
3. Token sent in `Authorization: Bearer <token>` header
4. Token automatically refreshed on login

### Important Notes

- Products can be browsed without authentication
- Orders require authentication
- Client role restricted access (can't create products, see other clients)

## epharma Configuration

### Purpose
Pharmacy staff management application for:
- Staff authentication
- Product inventory management
- Order management
- Sales tracking
- Activity logging
- Finance reports

### API Base URL

Similar auto-detection as client_app in `lib/services/api_constants.dart`

**For Web (Staff Dashboard):**
```bash
cd epharma
flutter run -d web
```

Access at `http://localhost:5000/api`

**For Android (Tablet/Phone):**
```bash
flutter run -d android
```

### Key Services

**auth_service.dart**
- `login()`: Staff authentication

**product_service.dart**
- `getProducts()`: Inventory management
- `createProduct()`: Add new products
- `updateProduct()`: Modify product details
- `updateStock()`: Adjust inventory

**sales_service.dart**
- `recordSale()`: Register purchase
- `getSales()`: View sales history

**finance_service.dart**
- `getFinanceSummary()`: View financial data
- `getReport()`: Generate reports

### Staff Roles

- **admin**: Full access to everything
- **pharmacien**: Can manage products and orders
- **assistant**: Can help with orders
- **caissier**: Can process payments

## Common Issues & Solutions

### Issue: "Cannot reach API"
**Cause:** Wrong API URL or server not running

**Solution:**
1. Verify API server is running: `npm run dev`
2. Check port 5000 is accessible
3. For Android emulator, use `http://10.0.2.2:5000/api`
4. For physical device, use machine IP instead of localhost

### Issue: "CORS error"
**Cause:** Client origin not in CORS_ORIGIN

**Solution:**
1. Get your machine/app IP
2. Add to API .env: `CORS_ORIGIN=...,http://your-ip:5000`
3. Restart API server

### Issue: "Unauthorized token"
**Cause:** Token expired (30 days) or invalid

**Solution:**
1. User needs to login again
2. Flutter apps handle this in AuthProvider
3. Check server JWT_SECRET matches

### Issue: "Page shows loading forever"
**Cause:** API request timeout

**Solution:**
1. Check API server console for errors
2. Verify MongoDB connection
3. Check network connectivity
4. Increase timeout in `api_service.dart` if needed

### Issue: "Cannot parse response"
**Cause:** API response format unexpected

**Solution:**
1. Verify API response format: `{success: true, data: ...}`
2. Check data types in Flutter models match API response
3. Review console logs for actual response

## Development Workflow

### Setup Phase
1. Start MongoDB: `net start MongoDB` (Windows)
2. Start API: `npm run dev` (in api folder)
3. Verify health: `curl http://localhost:5000/api/health`

### Development Phase
4. Start Flutter app: `flutter run`
5. Monitor logs in both terminals
6. Test features in app
7. Check API logs for issues

### Debugging
- **Flutter**: Use `flutter logs` or Android Studio logcat
- **API**: Check server console for request/error logs
- **Network**: Use Charles Proxy or Fiddler to inspect requests/responses

## Testing Checklist

### Before Deployment
- [ ] API server running and healthy
- [ ] MongoDB connection working
- [ ] At least one company created
- [ ] Test user account exists
- [ ] Login works in both apps
- [ ] Product listing works
- [ ] Order creation works (client_app)
- [ ] Product management works (epharma)
- [ ] No CORS errors
- [ ] No authentication errors
- [ ] No database connection errors

### Network Configuration for Different Environments

**Local Development (All on same machine)**
- API: http://localhost:5000
- Firebase: Not needed
- Database: mongodb://localhost:27017

**Emulator Development**
- API: http://10.0.2.2:5000 (Android), localhost (iOS)
- Database: mongodb://localhost:27017

**Production**
- API: https://api.production.com
- Firebase: Configured
- Database: mongodb+srv://user:pass@cluster...

## API Endpoints Used by Flutter Apps

### client_app Uses
```
POST   /api/auth/register-client
POST   /api/auth/login
GET    /api/auth/me
GET    /api/products
GET    /api/products/:id
GET    /api/clients/me
PUT    /api/clients/:me
POST   /api/orders
GET    /api/orders/my
GET    /api/orders/:id
```

### epharma Uses
```
POST   /api/auth/login
GET    /api/auth/me
GET    /api/products
POST   /api/products
PUT    /api/products/:id
PATCH  /api/products/:id/stock
GET    /api/orders
PATCH  /api/orders/:id/status
GET    /api/sales
POST   /api/sales
GET    /api/consultations
GET    /api/mouvements
GET    /api/dashboard/summary
```

## Code Example: Using API in Flutter

```dart
// Example: Fetching products
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Product>> fetchProducts(String companyId) async {
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/products?companyId=$companyId'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = json.decode(response.body);
    if (body['success']) {
      return (body['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }
  }
  throw Exception('Failed to load products');
}
```

## Performance Tips

1. **Pagination**: Use `limit` and `page` parameters
2. **Filtering**: Use query parameters to filter on server
3. **Caching**: Implement local caching for products
4. **Images**: Store images on separate CDN
5. **API Calls**: Debounce search queries

## Security Notes

1. **Never hardcode API URL** - use environment variables
2. **Secure token storage** - use SharedPreferences encrypted
3. **HTTPS in production** - always use HTTPS
4. **Validate input** - validate before sending to API
5. **Handle errors gracefully** - don't expose sensitive errors

## Monitoring

### API Server Logs
Check for:
- Database connection issues
- Authentication failures
- Validation errors
- Unhandled exceptions

### Flutter App Logs
```bash
flutter logs
```

### Network Inspection
Use Charles Proxy or Fiddler to inspect:
- Request headers (including Authorization)
- Request body
- Response status codes
- Response body

## Support

If apps can't connect to API:
1. Verify SETUP.md in api folder
2. Check API is running: `npm run dev`
3. Test health endpoint: curl http://localhost:5000/api/health
4. Review API_GUIDE.md for endpoint documentation
5. Check console logs in both API and Flutter

## Next Steps

1. Run API: `npm run dev`
2. Run client_app or epharma: `flutter run`
3. Create test accounts
4. Test all major flows
5. Monitor logs for issues
