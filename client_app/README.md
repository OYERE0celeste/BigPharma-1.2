# BigPharma 1.2 - Pharmaceutical Management System

A comprehensive Flutter + Node.js/Express pharmaceutical management application with multi-tenant support.

## Project Structure

```
├── lib/                    # Flutter client application
│   ├── main.dart          # App entry point (launches BigPharma HomePage)
│   ├── home.dart          # Main business interface with product catalog
│   └── widget_test.dart   # Unit & widget tests
├── api/                   # Node.js/Express backend
│   ├── models/            # MongoDB schemas
│   ├── routes/            # API endpoints
│   ├── middleware/        # Auth & validation
│   ├── utils/             # Helpers & utilities
│   ├── config/            # Configuration
│   └── tests/             # Integration tests
├── android/               # Android platform files
├── ios/                   # iOS platform files
└── web/                   # Web platform files
```

## Features

### Backend (Node.js/Express)
- **Multi-tenant Architecture**: Full isolation by `companyId`
- **Authentication**: JWT-based with role-based access control
- **Pharmacy Management**:
  - Product catalog with lot & expiration tracking
  - Client management
  - Sales transactions with FIFO stock management
  - Supplier tracking
  - Financial management & payment tracking
  - Activity audit logs
  - Stock movement history
- **RESTful API**: Comprehensive endpoints for all operations
- **Database**: MongoDB with Mongoose ODM

### Frontend (Flutter)
- **Responsive UI**: Desktop, tablet, and mobile layouts
- **Product Browsing**: Category-based product catalog
- **Order Management**: Shopping cart and purchase tracking
- **User Profile**: Account settings and preferences

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new company
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Password reset
- `POST /api/auth/update-me` - Update profile

### Products
- `GET /api/products` - List products
- `POST /api/products` - Add product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Archive product

### Sales
- `POST /api/sales` - Record sale
- `GET /api/sales/:id` - Get sale details
- `GET /api/sales/invoice/:invoiceNumber` - Get by invoice

### Finance
- `GET /api/finance` - List financial records
- `POST /api/finance` - Create finance entry
- `PUT /api/finance/:id` - Update payment status

### Clients
- `GET /api/clients` - List clients
- `POST /api/clients` - Create client
- `PUT /api/clients/:id` - Update client

### Dashboard
- `GET /api/dashboard/summary` - KPIs overview
- `GET /api/dashboard/sales-trend` - Sales trend analysis
- `GET /api/dashboard/finance-overview` - Finance summary

### Stock Management
- `GET /api/mouvements` - Stock movements history
- `POST /api/mouvements` - Log stock movement
- `GET /api/mouvements/product/:productId` - Product stock history

### Activity Logs
- `GET /api/activityLogs` - User activity history
- `POST /api/activityLogs` - Record activity

### Other
- `GET /api/suppliers` - Supplier list
- `GET /api/consultations` - Client consultations
- `GET /api/settings/profile` - User settings
- `GET /api/settings/company` - Company settings

## Getting Started

### Backend Setup
```bash
cd api
npm install
npm start
```

### Frontend Setup
```bash
flutter pub get
flutter run
```

### Environment Variables (Backend)
Create `.env` in `api/` directory:
```
MONGODB_URI=mongodb://127.0.0.1:27017/BigPharmaDB
JWT_SECRET=your_secret_key
PORT=5000
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
NODE_ENV=development
```

## Testing

### Backend Tests
```bash
cd api
npm test
```

### Frontend Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## Architecture Highlights

- **Multi-tenant**: Each user belongs to a company (`companyId`)
- **Role-based Access**: Admin, pharmacist, assistant, cashier, client roles
- **Audit Trail**: All activities logged with user, timestamp, and entity details
- **Stock Tracking**: FIFO with lot numbers and expiration dates
- **Transaction Safety**: Database transactions for atomic operations

## Tech Stack

**Frontend**:
- Flutter 3.10+
- Dart 3.10+
- Material Design 3

**Backend**:
- Node.js 18+
- Express 4.x
- MongoDB 5.0+
- Mongoose 7.x
- JWT for authentication
- Bcrypt for password hashing

## Development

### Running Backend
```bash
cd api
npm run dev  # With hot reload
```

### Running Frontend
```bash
flutter run -d <device_id>
```

## Notes

- The BigPharma interface uses green theme (Color: #2E7D62)
- All API responses follow standard format: `{ success, message, data, code }`
- Dates are stored as ISO 8601 strings
- Prices are stored as numbers (no decimals to avoid floating-point issues)

## License

Proprietary - BigPharma System

