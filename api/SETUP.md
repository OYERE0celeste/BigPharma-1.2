# BigPharma Backend API Setup & Integration Guide

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ installed
- MongoDB 4.4+ running locally or remote
- npm or yarn package manager

### Installation

1. **Install Dependencies**
   ```bash
   cd api
   npm install
   ```

2. **Configure Environment**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and set:
   - `MONGODB_URI`: Your MongoDB connection string
   - `JWT_SECRET`: A strong random string for JWT signing
   - `PORT`: Server port (default 5000)
   - `CORS_ORIGIN`: Comma-separated list of allowed origins

   Example for local development:
   ```env
   MONGODB_URI=mongodb://localhost:27017/BigPharmaDB
   JWT_SECRET=your-super-secret-key-min-32-characters-long
   PORT=5000
   NODE_ENV=development
   CORS_ORIGIN=http://localhost:3000,http://localhost:5000,http://127.0.0.1:5000,http://10.0.2.2:5000
   ```

3. **Start MongoDB** (if running locally)
   ```bash
   # Windows (if installed as service)
   net start MongoDB
   
   # macOS
   brew services start mongodb-community
   
   # Or run with Docker
   docker run -d -p 27017:27017 --name mongo mongo:latest
   ```

4. **Start the Server**
   ```bash
   # Development (with auto-reload)
   npm run dev
   
   # Production
   npm start
   ```

   Server should be running at `http://localhost:5000`

## ✅ Verify Setup

### Health Check
```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2024-04-17T...",
    "environment": "development"
  }
}
```

### Test Auth Endpoint
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

## 📱 Flutter App Integration

### client_app Configuration

The client_app automatically detects the API URL:
- **Web**: `http://localhost:5000/api`
- **Android Emulator**: `http://10.0.2.2:5000/api`
- **Physical Device**: Update `ApiConstants.baseUrl` with your machine IP

### epharma Configuration

Similarly, epharma uses the same API endpoint detection in `lib/services/api_constants.dart`.

### Ensure CORS is Configured

For Flutter Web and Android emulator:
```env
CORS_ORIGIN=http://localhost:3000,http://localhost:5000,http://127.0.0.1:5000,http://10.0.2.2:5000,http://192.168.x.x:5000
```

Replace `192.168.x.x` with your actual machine IP if using physical Android device.

## 🔑 Authentication Flow

### 1. Client Registration
```bash
curl -X POST http://localhost:5000/api/auth/register-client \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "password": "SecurePassword123",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "address": "123 Main St",
    "companyId": "YOUR_COMPANY_ID"
  }'
```

### 2. Client Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePassword123"
  }'
```

Response includes `token` - save this for authenticated requests.

### 3. Use Token in Requests
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 📋 Key API Endpoints

### Products (No Auth Required)
```bash
GET /api/products?page=1&limit=10&companyId=YOUR_COMPANY_ID
GET /api/products/:id
```

### Clients
```bash
POST /api/clients                    # Create (Admin)
GET /api/clients/me                  # Get own profile (Client)
GET /api/clients?companyId=ID       # List clients
PUT /api/clients/:id                # Update (Admin)
DELETE /api/clients/:id             # Delete (Admin)
```

### Orders (Auth Required)
```bash
POST /api/orders                     # Create order (Client)
GET /api/orders/my                   # My orders (Client)
GET /api/orders                      # All orders (Staff)
GET /api/orders/:id                 # Get order
PATCH /api/orders/:id/status        # Update status (Staff)
DELETE /api/orders/:id              # Cancel order
```

## 🐛 Troubleshooting

### "Cannot connect to MongoDB"
- Check MongoDB is running: `mongosh` or MongoDB Compass
- Verify MONGODB_URI in .env is correct
- Check firewall isn't blocking port 27017

### "Invalid JWT Secret"
- Ensure JWT_SECRET is set in .env
- It should be at least 32 characters long
- Restart server after changing

### "CORS error in Flutter"
- Verify client URL is in CORS_ORIGIN
- For Android emulator, ensure `http://10.0.2.2:5000/api` is included
- Restart server after updating CORS_ORIGIN

### "Token expired" in Flutter
- Tokens expire after 30 days
- User needs to login again to get a new token
- Flutter apps handle this with AuthProvider

### 404 on Endpoints
- Ensure route is registered in app.js
- Check controller file exists in controllers/
- Verify middleware chain is correct

## 🧪 Testing

### Run Tests
```bash
npm test
```

### Integration Tests
```bash
npm run test:api
```

## 📊 Database

### View Database (MongoDB Compass)
1. Open MongoDB Compass
2. Connect to: `mongodb://localhost:27017`
3. Database: `BigPharmaDB`

### Collections
- **users**: Store system users (admin, pharmacist, etc.)
- **clients**: Store customer profiles
- **products**: Store pharmacy products with lot tracking
- **orders**: Store customer orders
- **companies**: Store pharmacy company information
- **sales**: Store completed sales
- **prescriptions**: Store prescriptions
- And more...

### Sample Query (in MongoDB Compass)
```javascript
// Find all active products
db.products.find({ isActive: true })

// Find clients for a company
db.clients.find({ companyId: ObjectId("YOUR_COMPANY_ID") })

// Count orders for today
db.orders.countDocuments({ 
  createdAt: { 
    $gte: new Date(new Date().toDateString()) 
  }
})
```

## 🔐 Security Notes

1. **Change JWT_SECRET** in production
2. **Use environment variables** for all secrets
3. **NEVER commit .env file** to version control
4. **Use HTTPS** in production
5. **Rate limiting** is enabled on auth endpoints
6. **Passwords** are hashed with bcrypt (10 salt rounds)

## 📚 API Documentation

See `API_GUIDE.md` for:
- Complete endpoint documentation
- Request/response examples
- Error codes reference
- Authentication details
- Database schema

## 🚢 Deployment

### Production Checklist
- [ ] Set NODE_ENV=production
- [ ] Use strong JWT_SECRET (32+ characters)
- [ ] Configure CORS_ORIGIN for production domains
- [ ] Set up MongoDB with authentication
- [ ] Enable HTTPS
- [ ] Set up logging and monitoring
- [ ] Configure rate limiting appropriately
- [ ] Set up database backups
- [ ] Use environment-specific .env files

### Heroku Deployment Example
```bash
# Add buildpack for Node.js
heroku buildpacks:add heroku/nodejs

# Set environment variables
heroku config:set MONGODB_URI=<your_mongodb_uri>
heroku config:set JWT_SECRET=<strong_secret>
heroku config:set NODE_ENV=production

# Deploy
git push heroku main
```

## 📞 Support

For issues:
1. Check API_GUIDE.md for endpoint documentation
2. Review console logs for error messages
3. Verify .env configuration
4. Check MongoDB connection
5. Test endpoints with curl before using in app

## 📝 API Response Format

All responses follow this format:

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "extra": { /* optional pagination, metadata */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "User-friendly error message",
  "code": "ERROR_CODE",
  "data": null
}
```

## Next Steps

1. ✅ Complete setup above
2. ✅ Test API with curl commands
3. ✅ Create test company and users in database
4. ✅ Run client_app or epharma
5. ✅ Login and test features
6. ✅ Check console for any errors

Happy coding! 🎉
