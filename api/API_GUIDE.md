# BigPharma API Guide

## Overview

The BigPharma API is a Node.js/Express server that provides endpoints for managing pharmacy operations including:
- Authentication & Authorization
- Product Management
- Client Management  
- Orders
- Prescriptions
- Sales
- Finance
- Activity Logging

## Setup

### Prerequisites
- Node.js 16+
- MongoDB 4.4+
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file from `.env.example`:
```bash
cp .env.example .env
```

3. Configure your environment variables in `.env`:
```env
MONGODB_URI=mongodb://localhost:27017/BigPharmaDB
JWT_SECRET=your-super-secret-key-here
PORT=5000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000,http://localhost:5000,http://10.0.2.2:5000
```

### Running the Server

**Development** (with auto-reload):
```bash
npm run dev
```

**Production**:
```bash
npm start
```

## API Endpoints

### Authentication

#### Register Admin & Company
```
POST /api/auth/register
Content-Type: application/json

{
  "name": "Pharmacy Name",
  "email": "pharmacy@example.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "City",
  "country": "Country",
  "fullName": "Admin Name",
  "adminEmail": "admin@pharmacy.com",
  "password": "securePassword123"
}
```

#### Register Client
```
POST /api/auth/register-client
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890",
  "password": "securePassword123",
  "dateOfBirth": "1990-01-15",
  "gender": "male",
  "address": "456 Oak St",
  "companyId": "64f1a2b3c4d5e6f7g8h9i0j1"
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGc...",
    "user": {
      "id": "64f1...",
      "fullName": "John Doe",
      "email": "john@example.com",
      "role": "client",
      "companyId": "64f1..."
    },
    "company": {
      "id": "64f1...",
      "name": "Pharmacy Name"
    }
  }
}
```

#### Get Current User
```
GET /api/auth/me
Authorization: Bearer <token>
```

#### Update Profile
```
PUT /api/auth/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "fullName": "New Name",
  "phone": "+1234567890",
  "address": "New Address"
}
```

#### Change Password
```
POST /api/auth/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "currentPassword": "oldPassword123",
  "newPassword": "newSecurePassword123"
}
```

### Products

#### Get Products
```
GET /api/products?page=1&limit=10&search=aspirin&category=pain-relief&companyId=...
Authorization: Bearer <token> (optional)
```

**Query Parameters**:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10)
- `search`: Search by name or description
- `category`: Filter by category
- `stockStatus`: Filter by status (out_of_stock, low_stock, expired, near_expiration)
- `companyId`: Company ID (required if not authenticated)

#### Get Product by ID
```
GET /api/products/:id
Authorization: Bearer <token> (optional)
```

#### Create Product (Admin only)
```
POST /api/products
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Aspirin",
  "category": "Pain Relief",
  "description": "Acetylsalicylic acid",
  "purchasePrice": 0.50,
  "sellingPrice": 2.00,
  "lowStockThreshold": 20,
  "minStockLevel": 10,
  "prescriptionRequired": false,
  "lots": [
    {
      "lotNumber": "LOT001",
      "quantity": 100,
      "quantityAvailable": 100,
      "costPrice": 0.50,
      "expirationDate": "2025-12-31"
    }
  ]
}
```

### Clients

#### Get Clients
```
GET /api/clients?page=1&limit=10&companyId=...
Authorization: Bearer <token> (optional)
```

#### Get My Profile (Client only)
```
GET /api/clients/me
Authorization: Bearer <token>
```

#### Create Client (Admin only)
```
POST /api/clients
Authorization: Bearer <token>
Content-Type: application/json

{
  "fullName": "Jane Smith",
  "email": "jane@example.com",
  "phone": "9876543210",
  "dateOfBirth": "1985-05-20",
  "gender": "female",
  "address": "789 Elm St",
  "createUser": true,
  "password": "clientPassword123"
}
```

#### Update Client (Admin only)
```
PUT /api/clients/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "fullName": "Jane Smith Updated",
  "phone": "9876543210",
  "address": "New Address"
}
```

### Orders

#### Create Order (Client only)
```
POST /api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "products": [
    {
      "productId": "64f1...",
      "quantity": 2,
      "price": 4.00
    }
  ],
  "totalAmount": 8.00,
  "notes": "Urgent delivery needed"
}
```

#### Get My Orders (Client)
```
GET /api/orders/my
Authorization: Bearer <token>
```

#### Get All Orders (Admin/Staff)
```
GET /api/orders?page=1&limit=10
Authorization: Bearer <token>
```

#### Get Order by ID
```
GET /api/orders/:id
Authorization: Bearer <token>
```

#### Update Order Status (Admin/Staff)
```
PATCH /api/orders/:id/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "confirmed",
  "notes": "Order confirmed and ready for pickup"
}
```

#### Cancel Order
```
DELETE /api/orders/:id
Authorization: Bearer <token>
```

## Authentication

All protected endpoints require an `Authorization` header with a Bearer token:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### User Roles

- **admin**: Full access to all features
- **pharmacien**: Pharmacy staff, can manage products and orders
- **assistant**: Pharmacy assistant
- **caissier**: Cashier, can process orders/sales
- **client**: Regular customer, limited access

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "message": "Description of the error",
  "code": "ERROR_CODE",
  "data": null
}
```

### Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Missing or invalid fields |
| UNAUTHORIZED | 401 | Missing or invalid token |
| INVALID_CREDENTIALS | 401 | Wrong email/password |
| ACCOUNT_INACTIVE | 403 | User account is disabled |
| DUPLICATE_ENTRY | 409 | Email/phone already exists |
| NOT_FOUND | 404 | Resource not found |
| SERVER_ERROR | 500 | Internal server error |

## CORS Configuration

The API allows requests from:
- http://localhost:3000
- http://localhost:5000  
- http://localhost:8080
- http://127.0.0.1:5000
- http://10.0.2.2:5000 (Android emulator)

Configure additional origins in `.env` using `CORS_ORIGIN`.

## Rate Limiting

Authentication endpoints are rate-limited to 100 requests per 15 minutes per IP.

## Database Schema

### Collections

**Users**
- fullName: String
- email: String (unique)
- passwordHash: String
- role: String (admin, pharmacien, assistant, caissier, client)
- phone: String
- address: String
- companyId: ObjectId (reference to Company)
- isActive: Boolean
- lastLoginAt: Date

**Clients**
- fullName: String
- email: String
- phone: String
- dateOfBirth: Date
- gender: String (male, female)
- address: String
- companyId: ObjectId
- userId: ObjectId (reference to User)
- totalPurchases: Number
- totalSpent: Number
- lastVisit: Date

**Products**
- name: String
- category: String
- description: String
- purchasePrice: Number
- sellingPrice: Number
- prescriptionRequired: Boolean
- stockQuantity: Number
- lots: [Lot]
- companyId: ObjectId
- isActive: Boolean

**Lot**
- lotNumber: String
- quantity: Number
- quantityAvailable: Number
- costPrice: Number
- expirationDate: Date

## Testing

Run tests with:
```bash
npm test
```

## Troubleshooting

### Database Connection Error
- Ensure MongoDB is running
- Check MONGODB_URI in .env
- Verify database credentials

### Token Invalid Error
- Token may have expired (30 day expiration)
- Re-login to get a new token
- Check JWT_SECRET matches in .env

### CORS Error
- Ensure your client URL is in CORS_ORIGIN in .env
- Restart the server after changing CORS_ORIGIN

## Development Notes

- All timestamps are in UTC
- Dates should be ISO 8601 format
- Soft deletes are used (isActive flag) instead of hard deletes
- Activity logging tracks all major operations
- Transactions are used for operations that modify multiple documents

## Contributing

1. Create a feature branch
2. Make changes and test
3. Ensure error codes are consistent
4. Update this guide if adding new endpoints
5. Submit PR for review
