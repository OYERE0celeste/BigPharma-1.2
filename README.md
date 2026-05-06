# BigPharma - Pharmaceutical Management System

A complete pharmaceutical management system with a Node.js/Express backend API and Flutter frontend applications for both customer and staff management.

## Project Structure

```
BigPharma 1.2/
├── api/                          # Node.js/Express Backend
│   ├── app.js                   # Express app configuration
│   ├── server.js                # Server entry point
│   ├── package.json             # Dependencies
│   ├── .env.example             # Environment configuration template
│   ├── API_GUIDE.md             # Complete API documentation
│   ├── SETUP.md                 # Setup and troubleshooting guide
│   │
│   ├── config/
│   │   ├── db.js                # MongoDB connection
│   │   └── env.js               # Environment validation
│   │
│   ├── models/                  # MongoDB schemas
│   │   ├── User.js              # User accounts
│   │   ├── Client.js            # Client profiles
│   │   ├── Product.js           # Pharmacy products
│   │   ├── Order.js             # Customer orders
│   │   ├── Sale.js              # Completed sales
│   │   ├── Prescription.js      # Medical prescriptions
│   │   └── ...
│   │
│   ├── controllers/             # Business logic
│   │   ├── authController.js    # Authentication
│   │   ├── productController.js # Product management
│   │   ├── clientController.js  # Client management
│   │   ├── orderController.js   # Order management
│   │   └── ...
│   │
│   ├── routes/                  # API endpoints
│   │   ├── auth.js              # /api/auth endpoints
│   │   ├── products.js          # /api/products endpoints
│   │   ├── clients.js           # /api/clients endpoints
│   │   ├── orders.js            # /api/orders endpoints
│   │   └── ...
│   │
│   ├── middleware/              # Express middleware
│   │   ├── authMiddleware.js    # Authentication checker
│   │   ├── roleMiddleware.js    # Role-based access control
│   │   ├── errorMiddleware.js   # Global error handling
│   │   └── ...
│   │
│   ├── utils/                   # Utility functions
│   │   ├── response.js          # Standardized responses
│   │   ├── activityLogger.js    # Activity logging
│   │   └── ...
│   │
│   └── tests/                   # Test files
│
├── client_app/                  # Flutter Mobile App (Customer)
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── home.dart            # Home screen
│   │   │
│   │   ├── services/            # API & Business logic
│   │   │   ├── api_constants.dart    # API URLs
│   │   │   ├── api_service.dart      # HTTP client
│   │   │   ├── auth_service.dart     # Authentication
│   │   │   ├── product_service.dart  # Products
│   │   │   ├── auth_provider.dart    # State management
│   │   │   └── ...
│   │   │
│   │   ├── models/              # Data models
│   │   │   ├── user.dart
│   │   │   ├── product.dart
│   │   │   ├── order.dart
│   │   │   └── ...
│   │   │
│   │   ├── pages/               # Screens
│   │   │   ├── login_page.dart
│   │   │   ├── products_page.dart
│   │   │   └── ...
│   │   │
│   │   └── widgets/             # Reusable components
│   │
│   ├── pubspec.yaml             # Flutter dependencies
│   └── android/, ios/           # Platform-specific code
│
├── epharma/                     # Flutter Web App (Customer & Staff Platform)
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── pharmacy_dashboard_page.dart # Main dashboard
│   │   │
│   │   ├── services/            # API & Business logic
│   │   │   ├── api_constants.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── product_service.dart
│   │   │   └── ...
│   │   │
│   │   ├── providers/           # State management
│   │   │   └── ...
│   │   │
│   │   ├── models/              # Data models
│   │   │   └── ...
│   │   │
│   │   ├── screens/             # Major screens
│   │   │   ├── products/
│   │   │   ├── commandes/
│   │   │   ├── finances/
│   │   │   └── ...
│   │   │
│   │   └── widgets/             # Components
│   │
│   ├── pubspec.yaml
│   ├── web/                     # Web assets
│   └── ...
│
├── FLUTTER_API_INTEGRATION.md   # Flutter integration guide
└── README.md                    # This file
```

## Features

### 🛒 Customer Portal (client_app)
- User registration and authentication
- Browse pharmacy products
- Shopping cart management
- Place and track orders
- View order history
- Manage personal profile
- Prescription viewing

### 💼 Web Platform (epharma)
The `epharma` directory contains the unified web platform for the BigPharma system. It is a **hybrid application** that dynamically adapts its interface based on the authenticated user's role:

- **For Customers**: Provides a full-featured web version of the portal (browsing, ordering, profile management).
- **For Staff (Admin, Pharmacist, etc.)**: Provides the professional management dashboard for inventory, sales, finances, and operations.

### 🔐 API Features
- JWT token-based authentication
- Role-based access control (admin, pharmacien, assistant, caissier, client)
- Multi-company support (multi-tenancy)
- Comprehensive product lot tracking
- Order lifecycle management
- Activity audit logging
- Error handling with standardized codes
- CORS support for web and mobile
- Rate limiting on authentication endpoints
- Soft delete support

## Technology Stack

### Backend
- **Runtime**: Node.js 16+
- **Framework**: Express.js 5.x
- **Database**: MongoDB 4.4+
- **Authentication**: JWT (jsonwebtoken)
- **Security**: bcryptjs, helmet
- **Validation**: Joi
- **Testing**: Jest, Supertest

### Frontend (Mobile & Web)
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **UI Components**: Material Design 3

## Getting Started

### Prerequisites
- Node.js 16+
- MongoDB 4.4+
- Flutter 3.x (for running apps)
- npm/yarn package manager

### 1. Setup Backend (API)

```bash
cd api
cp .env.example .env
```

Edit `.env`:
```env
MONGODB_URI=mongodb://localhost:27017/BigPharmaDB
JWT_SECRET=your-super-secret-key
PORT=5000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000,http://localhost:5000,http://10.0.2.2:5000
```

Start MongoDB:
```bash
# Windows (if service installed)
net start MongoDB

# macOS
brew services start mongodb-community

# Docker
docker run -d -p 27017:27017 --name mongo mongo:latest
```

Start API:
```bash
npm install
npm run dev
```

Verify: `curl http://localhost:5000/api/health`

### 2. Run Client App

**Android Emulator:**
```bash
cd client_app
flutter pub get
flutter run
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d web
```

### 3. Run Staff Dashboard (epharma)

**Web:**
```bash
cd epharma
flutter pub get
flutter run -d web
```

**Android:**
```bash
flutter run -d android
```

## API Endpoints

See `api/API_GUIDE.md` for complete API documentation.

### Quick Reference

**Authentication**
```
POST   /api/auth/register          # Admin registration
POST   /api/auth/register-client   # Client registration
POST   /api/auth/login             # Login
GET    /api/auth/me                # Current user
PUT    /api/auth/me                # Update profile
POST   /api/auth/change-password   # Change password
```

**Products**
```
GET    /api/products               # List products
GET    /api/products/:id           # Get product details
POST   /api/products               # Create (Admin only)
PUT    /api/products/:id           # Update (Admin only)
DELETE /api/products/:id           # Delete (Admin only)
```

**Clients**
```
GET    /api/clients                # List clients
GET    /api/clients/me             # My profile
POST   /api/clients                # Create (Admin only)
PUT    /api/clients/:id            # Update (Admin only)
```

**Orders**
```
POST   /api/orders                 # Create order
GET    /api/orders/my              # My orders
GET    /api/orders                 # All orders (Staff)
PATCH  /api/orders/:id/status      # Update status
DELETE /api/orders/:id             # Cancel order
```

## User Roles

| Role | Capabilities |
|------|---|
| **admin** | Full system access, user management, company settings |
| **pharmacien** | Product management, order handling, inventory |
| **assistant** | Order assistance, inventory viewing |
| **caissier** | Process payments, record sales |
| **client** | Browse products, place orders, view profile |

## Database Schema

### Core Collections
- **users**: System users with authentication
- **clients**: Customer profiles
- **products**: Pharmacy inventory with lot tracking
- **orders**: Customer orders
- **sales**: Completed transactions
- **companies**: Pharmacy company information
- **prescriptions**: Medical prescriptions
- **consultations**: Doctor consultations
- **activityLogs**: System activity tracking

## Authentication Flow

1. User registers or logs in
2. API returns JWT token (30-day expiration)
3. Token stored securely in app (SharedPreferences for Flutter)
4. Token sent in `Authorization: Bearer <token>` header
5. API validates token on protected endpoints
6. On expiration, user must log in again

## Error Codes Reference

| Code | HTTP Status | Meaning |
|------|---|---|
| VALIDATION_ERROR | 400 | Missing or invalid fields |
| UNAUTHORIZED | 401 | Missing authentication token |
| INVALID_CREDENTIALS | 401 | Wrong email/password |
| ACCOUNT_INACTIVE | 403 | User account disabled |
| DUPLICATE_ENTRY | 409 | Email/phone already exists |
| NOT_FOUND | 404 | Resource not found |
| SERVER_ERROR | 500 | Internal server error |

See `api/API_GUIDE.md` for complete error codes list.

## Configuration

### API Environment Variables
- `MONGODB_URI`: MongoDB connection string
- `JWT_SECRET`: JWT signing secret (min 32 characters)
- `PORT`: Server port (default: 5000)
- `NODE_ENV`: development/production
- `CORS_ORIGIN`: Comma-separated list of allowed origins
- `FEATURE_2FA_ENABLED`: Enable two-factor authentication

### Flutter App Configuration

Auto-detects API URL:
- **Web/localhost**: `http://localhost:5000/api`
- **Android emulator**: `http://10.0.2.2:5000/api`
- **Physical device**: `http://<machine-ip>:5000/api`

Override in `lib/services/api_constants.dart` if needed.

## Development Guide

### Adding a New API Endpoint

1. Create model in `api/models/`
2. Create controller in `api/controllers/`
3. Create route in `api/routes/`
4. Register route in `api/app.js`
5. Add to API_GUIDE.md documentation

### Adding a New Flutter Screen

1. Create service in `lib/services/` if needed
2. Create models in `lib/models/` if needed
3. Create provider in `lib/providers/` for state
4. Create page in `lib/pages/` or `lib/screens/`
5. Add widgets in `lib/widgets/` for reusable components
6. Update navigation in main app

## Testing

### API Tests
```bash
cd api
npm test
npm run test:api
```

### Flutter Tests
```bash
cd client_app
flutter test
```

## Troubleshooting

### API Won't Start
- Check MongoDB is running
- Check PORT 5000 is available
- Verify MONGODB_URI is correct
- Check Node.js version (16+)

### Flutter Can't Connect to API
- For emulator: ensure `http://10.0.2.2:5000/api` is used
- For device: check network connectivity and update IP in api_constants
- Verify API CORS includes your client URL
- Check API server is running: `curl http://localhost:5000/api/health`

### CORS Errors
- Add your client URL to `CORS_ORIGIN` in `.env`
- For Android emulator add: `http://10.0.2.2:5000`
- For device add: `http://<your-machine-ip>:5000`
- Restart API server after changes

### Authentication Issues
- Token expired? User must log in again
- Token invalid? Check JWT_SECRET is configured
- Check Authorization header format: `Bearer <token>`

## Documentation

- **API_GUIDE.md** - Complete API endpoint documentation
- **SETUP.md** - Detailed setup and troubleshooting
- **FLUTTER_API_INTEGRATION.md** - Flutter integration guide
- **health-check.sh** - Quick health check script

## Security Considerations

1. **Never commit .env file** to version control
2. **Use strong JWT_SECRET** (32+ characters)
3. **Enable HTTPS** in production
4. **Configure database authentication**
5. **Set up database backups**
6. **Enable rate limiting** appropriately
7. **Keep dependencies updated**
8. **Use environment-specific secrets**

## Deployment

### Production Checklist
- [ ] Set NODE_ENV=production
- [ ] Configure production MongoDB
- [ ] Use strong JWT_SECRET
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS for production domains
- [ ] Set up logging and monitoring
- [ ] Configure database backups
- [ ] Test all functionality
- [ ] Set up CI/CD pipeline
- [ ] Document deployment process

### Deployment Platforms
- **API**: Heroku, Railway, Fly.io, AWS, DigitalOcean
- **Flutter Web**: Firebase Hosting, Netlify, Vercel
- **Flutter Mobile**: Google Play Store, Apple App Store

## Support & Contributing

For issues or contributions:
1. Check documentation files
2. Review API and Flutter integration guides
3. Check GitHub issues/discussions
4. Create detailed bug reports

## License

[Your License Here]

## Contact

[Your Contact Information]

---

**Last Updated**: April 2024
**Version**: 1.2
**Status**: Production Ready ✅
