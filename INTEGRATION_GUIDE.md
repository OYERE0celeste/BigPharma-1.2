# BigPharma Sales Integration Guide

## 📁 Files Modified & Created

### Created Files
- ✅ `lib/pharmacy_sales_page.dart` - Complete POS system (1700+ lines)

### Modified Files
- ✅ `lib/main.dart` - Added routes and imports
- ✅ `lib/pharmacy_dashboard_page.dart` - Added Sales navigation
- ✅ `lib/pharmacy_products_page.dart` - Added Sales navigation
- ✅ `pubspec.yaml` - Added `intl: ^0.19.0` dependency

## 🚀 Getting Started

### 1. Update Dependencies
```bash
cd epharma
flutter pub get
```

### 2. Navigation Setup
The routing has been configured in `main.dart`:
```dart
initialRoute: '/',
routes: {
  '/': (context) => const PharmacyDashboardPage(),
  '/products': (context) => const PharmacyProductsPage(),
  '/sales': (context) => const PharmacySalesPage(),
},
```

### 3. Access the POS Page
From any page in the app, navigate to Sales via:
- **Sidebar**: Click the "Sales" menu item
- **Programmatic**: Used MaterialPageRoute with PharmacySalesPage()

## 🏗️ Architecture Overview

```
pharmacy_sales_page.dart
├── Models
│   ├── Product
│   ├── Lot
│   ├── CartItem
│   ├── Sale
│   ├── StockStatus (enum)
│   ├── PaymentMethod (enum)
├── Service Layer
│   └── SalesService (Singleton)
├── Reusable Widgets
│   ├── ProductCard
│   ├── StatusBadge
│   ├── CartItemTile
│   ├── PrescriptionBanner
│   ├── TransactionSummaryPanel
│   ├── PaymentSection
│   └── SaleHistoryTable
└── Main Page
    └── PharmacySalesPage (StatefulWidget)
```

## 🎯 Key Features

### 1. Product Management
```dart
// Get all products
final products = SalesService().getMockProducts();

// Check stock
final available = product.getAvailableStock();
final status = product.getStockStatus();

// Get best lot (FIFO)
final lot = product.getNearestExpirationLot();
```

### 2. Cart Operations
```dart
// Add item
_addProductToCart(product);

// Modify quantity
cartItem.quantity++;
cartItem.quantity--;

// Get subtotal
final subtotal = cartItem.getSubtotal();
```

### 3. Sale Processing
```dart
// Create sale
final sale = SalesService().createSale(
  items: _cart,
  discountAmount: _customDiscount,
  taxAmount: _customTax,
  paymentMethod: 'cash',
  amountReceived: _amountReceived,
  prescriptionVerified: _prescriptionVerified,
);

// Retrieve history
final history = SalesService().getSalesHistory();
```

## 💾 Data Model Examples

### Product Example
```dart
Product(
  id: 'P001',
  name: 'Amoxicillin 500mg',
  category: 'Antibiotics',
  sellingPrice: 5.50,
  totalStock: 150,
  prescriptionRequired: true,
  lots: [
    Lot(
      lotNumber: 'LOT-2024-001',
      manufacturingDate: DateTime(2023, 1, 15),
      expirationDate: DateTime(2026, 1, 15),
      quantityAvailable: 150,
      costPrice: 2.00,
    ),
  ],
)
```

### Sale Example
```dart
Sale(
  invoiceNumber: 'INV-2026-1001',
  dateTime: DateTime.now(),
  items: [cartItem1, cartItem2],
  subtotal: 25.50,
  discountAmount: 0.0,
  taxAmount: 2.55,
  totalAmount: 28.05,
  paymentMethod: 'cash',
  amountReceived: 30.00,
  changeAmount: 1.95,
  pharmacistName: 'Pharmacist John Doe',
  prescriptionVerified: true,
)
```

## 🔌 Future API Integration

### Replace Mock Service
```dart
// Current: Mock data in SalesService
class SalesService {
  List<Product> getMockProducts() {
    // Return mock data
  }
}

// Future: API calls
class SalesService {
  Future<List<Product>> getProducts() async {
    final response = await http.get('/api/products');
    // Parse and return
  }
}
```

### Backend Endpoints Needed
```
GET    /api/products              - Fetch all products
GET    /api/products/:id/lots     - Get lot history
POST   /api/sales                 - Create sale
GET    /api/sales                 - Get sales history
GET    /api/sales?date=YYYY-MM-DD - Filter by date
PATCH  /api/inventory/:id         - Deduct stock
POST   /api/prescriptions/upload  - Upload prescription
```

## 📊 State Management

The page uses `StatefulWidget` with setState for simplicity. For future scaling:

### Recommended Improvements
1. **Provider Pattern**: For multi-page state sharing
2. **GetX**: For reactive state management
3. **Bloc**: For complex business logic
4. **Riverpod**: For dependency injection

### Current State Variables
```dart
final List<CartItem> _cart = [];
bool _showSalesHistory = false;
bool _prescriptionVerified = false;
double _customDiscount = 0;
double _customTax = 0;
double _amountReceived = 0;
PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
```

## 🎨 Customization Points

### Colors
Edit `lib/app_colors.dart`:
```dart
const Color kPrimaryGreen = Color(0xFF2E7D32);
const Color kAccentBlue = Color(0xFF0288D1);
const Color kDangerRed = Color(0xFFD32F2F);
const Color kWarningOrange = Color(0xFFF57C00);
```

### Styling
- Product grid: Adjust `childAspectRatio` in GridView
- Sidebar width: Edit in `app_sidebar.dart`
- Panel ratio: Modify `flex` values in Row widgets

### Mock Data
Replace products in `SalesService.getMockProducts()` with real data or API calls.

## 🧪 Testing

### Manual Testing Checklist
- [ ] Add product to cart
- [ ] Increase/decrease quantity
- [ ] Remove item from cart
- [ ] Apply discount
- [ ] Verify change calculation
- [ ] Switch payment methods
- [ ] Confirm sale with Rx items
- [ ] Filter sales history by date
- [ ] Search products

### Unit Tests (Future)
```dart
test('CartItem calculates subtotal correctly', () {
  final item = CartItem(/* ... */);
  expect(item.getSubtotal(), 25.50);
});

test('Sale calculates total with tax and discount', () {
  final sale = Sale(/* ... */);
  expect(sale.totalAmount, 28.05);
});
```

## 📱 Responsive Considerations

### Current Layout
- **Left Panel**: 60% width (Product selection)
- **Right Panel**: 40% width (Cart & payment)
- **Mobile Support**: Not implemented (requires refactoring)

### Future Mobile Support
```dart
if (MediaQuery.of(context).size.width < 900) {
  // Show stacked layout for tablets
} else {
  // Show current two-panel layout
}
```

## 🔐 Security Considerations

### Currently Not Implemented (Add Before Production)
1. **User Authentication**: Identify pharmacist
2. **Authorization**: Role-based access
3. **Audit Logging**: Track all transactions
4. **Data Encryption**: Secure storage
5. **Input Validation**: Sanitize all inputs
6. **Rate Limiting**: API call throttling

### Before Going Live
- [ ] Add user authentication
- [ ] Implement audit log
- [ ] Encrypt sensitive data
- [ ] Add input validation
- [ ] Setup error monitoring
- [ ] Implement rate limiting

## 🐛 Troubleshooting

### Common Issues

**Issue**: Icons not found
- Solution: Ensure Flutter is updated to latest stable version

**Issue**: intl package import fails
- Solution: Run `flutter pub get` and rebuild

**Issue**: Sidebar navigation doesn't work
- Solution: Verify callbacks are properly passed

## 📈 Performance Optimization

### Current Implementation
- Mock data generated on first access
- GridView uses ShrinkWrap (avoid for large lists)
- Lazy loading of products

### Optimization Tips
1. Use `ListView.builder` for large product lists
2. Implement pagination for sales history
3. Cache product images
4. Use `const` constructors where possible
5. Implement virtual scrolling for large tables

## 🔄 Integration Timeline

### Phase 1: Current (Mock Data)
- ✅ UI/UX Implementation
- ✅ Local state management
- ✅ Business logic
- ✅ Mock data

### Phase 2: Backend Integration (Week 1-2)
- [ ] Replace mock service with API calls
- [ ] Add product image loading
- [ ] Implement real inventory tracking
- [ ] Setup sales database

### Phase 3: Advanced Features (Week 3-4)
- [ ] Barcode scanning
- [ ] Prescription upload
- [ ] Multi-currency support
- [ ] Receipt printing

### Phase 4: Production (Week 5+)
- [ ] Authentication
- [ ] Audit logging
- [ ] Performance optimization
- [ ] Testing & QA

## 📞 Support Resources

- Flutter Documentation: https://flutter.dev/docs
- Material 3 Spec: https://m3.material.io
- Dart Formatting: Run `flutter format lib/`
- Code Analysis: Run `flutter analyze`

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-15 | Initial POS system with mock data |

---

**Last Updated**: February 15, 2026  
**Maintainer**: BigPharma Development Team  
**Status**: ✅ Production Ready (Mock Data)
