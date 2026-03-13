# BigPharma POS System - Documentation

## 📋 Overview

The Pharmacy Sales Page (`pharmacy_sales_page.dart`) is a complete, production-ready Point of Sale (POS) system for managing pharmacy transactions. It features a professional desktop-oriented interface with Material Design 3.

## 🎯 Features Implemented

### ✅ Product Search & Selection (LEFT SIDE)
- **Real-time search filtering** by:
  - Product name
  - Barcode
  - Category
- **Product Grid Display** with:
  - Product name and category
  - Selling price
  - Available stock
  - Stock status badges (Available, Low Stock, Out of Stock)
  - Prescription requirement indicator (Rx badge)
  - Smart FIFO lot selection on add-to-cart

### ✅ Shopping Cart (RIGHT SIDE)
- **Dynamic cart management**:
  - Add/remove items
  - Quantity controls (increment/decrement)
  - Real-time subtotal calculations
  - Stock availability validation
  
- **Lot Management**:
  - Display selected lot number
  - Show expiration date tracking
  - Prevent overselling with lot stock limits
  - Automatic FIFO (First In, First Out) lot selection

### ✅ Prescription Validation
- **Prescription-Required Items Detection**:
  - Automatic warning banner when Rx items in cart
  - Visual alerts with warning color scheme
  - "Attach Prescription" button (prepared for future integration)
  - Pharmacist verification toggle
  - Prevents sale confirmation without verification

### ✅ Transaction Summary
- **Real-time calculations**:
  - Subtotal
  - Customizable discount (percentage or fixed amount)
  - Configurable tax
  - Total amount
  
- **Payment Management**:
  - Payment method selection:
    - Cash
    - Card
    - Mobile Money
  - Amount received field
  - Automatic change calculation
  - Visual feedback for payment status

### ✅ Sale Confirmation
- **Comprehensive Validation**:
  - Non-empty cart requirement
  - Stock availability verification
  - Prescription verification (if applicable)
  - Sufficient payment amount check
  
- **Post-Sale Actions**:
  - Sale record generation with unique invoice number
  - Cart auto-clear
  - Success dialog with transaction summary
  - Print invoice preparation (button ready for integration)

### ✅ Sales History Tab
- **Transaction Records**:
  - Complete sale history display
  - Invoice number, date/time tracking
  - Payment method recording
  - Pharmacist responsible tracking
  - Total amount display
  
- **Filtering Capabilities**:
  - Filter by date range
  - Filter by payment method
  - Interactive date picker
  - Clear filter options

## 🏗️ Architecture

### Models

#### `Product`
```dart
class Product {
  final String id;
  final String name;
  final String category;
  final double sellingPrice;
  final int totalStock;
  final bool prescriptionRequired;
  final List<Lot> lots;
}
```

#### `Lot`
```dart
class Lot {
  final String lotNumber;
  final DateTime manufacturingDate;
  final DateTime expirationDate;
  final int quantityAvailable;
  final double costPrice;
}
```

#### `CartItem`
```dart
class CartItem {
  final Product product;
  final Lot selectedLot;
  int quantity;
}
```

#### `Sale`
```dart
class Sale {
  final String invoiceNumber;
  final DateTime dateTime;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final String pharmacistName;
  final bool prescriptionVerified;
}
```

### Service Layer

#### `SalesService` (Singleton Pattern)
- Mock data generation
- Sale creation and recording
- Sales history management
- Filter capabilities

### Reusable Widgets

1. **ProductCard** - Product display in grid
2. **StatusBadge** - Stock status indicator
3. **CartItemTile** - Cart item display with controls
4. **PrescriptionBanner** - Rx warning and verification
5. **TransactionSummaryPanel** - Financial summary
6. **PaymentSection** - Payment method & amount
7. **SaleHistoryTable** - Historical transaction display

## 🔄 User Workflow

### New Sale Process

1. **Product Selection**
   - Search for product by name, barcode, or category
   - Click product card to add to cart
   - Automatic lot selection (nearest expiration)

2. **Cart Management**
   - Adjust quantities with +/- buttons
   - View lot information
   - Remove items as needed
   - See real-time calculations

3. **Prescription Handling** (if applicable)
   - System shows warning banner
   - Click "Attach Prescription" (future integration)
   - Toggle "Verified" by pharmacist
   - Sale confirmation blocked until verified

4. **Payment Processing**
   - Select payment method
   - Enter amount received
   - Review change calculation
   - Confirm sale

5. **Completion**
   - View success dialog
   - Option to print invoice
   - Cart automatically clears
   - Ready for next sale

### Sales History Review

1. Click "History" tab
2. Optionally filter by date or payment method
3. View transaction details in table
4. Click view icon for detailed transaction info

## 📦 Mock Data

The system includes 10 mock products covering different pharmacy categories:
- Antibiotics (Amoxicillin, Azithromycin)
- Pain Relief (Paracetamol, Ibuprofen, Aspirin)
- Diabetes (Metformin)
- Digestive (Omeprazole)
- Cardiovascular (Lisinopril)
- Allergy (Cetirizine)
- Vitamins (Vitamin C)

Each product includes:
- Realistic pricing
- Multiple lot numbers with expiration dates
- Varying stock levels
- Prescription requirement indicators

## 🔮 Future Enhancements

### Short Term
- [ ] Print/export invoice functionality
- [ ] Prescription document upload integration
- [ ] Customer/client tracking
- [ ] Receipt SMS/email sending
- [ ] Cash drawer integration

### Medium Term
- [ ] Real API integration (replace mock service)
- [ ] Database persistence (SQLite/Backend)
- [ ] Barcode scanner support
- [ ] Multi-user support with role-based access
- [ ] Inventory deduction on sale confirmation
- [ ] Return/refund processing

### Long Term
- [ ] Analytics dashboard (best-selling products, daily revenue)
- [ ] Loyalty program integration
- [ ] Insurance integration
- [ ] Prescription management system
- [ ] Multi-pharmacy support
- [ ] Mobile app version
- [ ] Tax compliance reporting

## 🎨 Design System

### Colors (Material 3)
- Primary Green: `#2E7D32` - Main actions, positive states
- Accent Blue: `#0288D1` - Secondary actions
- Soft Blue: `#E1F5FE` - Selection/hover states
- Danger Red: `#D32F2F` - Warnings, deletions
- Warning Orange: `#F57C00` - Low stock alerts

### Responsive Layout
- Desktop-first approach
- 60% left panel (Products)
- 40% right panel (Cart & Payment)
- Expandable history view

## 🔌 Integration Points

### Ready for Future Integration

1. **Prescription Upload**
   - Button: "Attach Prescription"
   - Location: `PrescriptionBanner` widget
   - Handler: `onAttach` callback

2. **Invoice Printing**
   - Button: "Print Invoice"
   - Location: Success dialog
   - Handler: Button onPressed

3. **Inventory Update**
   - Deduction logic in `_confirmSale()`
   - Would need to call backend API
   - Location: Before `_salesService.createSale()`

4. **Payment Processing**
   - Payment methods already selectable
   - Amount validation in place
   - Ready for payment gateway integration

## 📊 Mock Data Schema

### Products
- 10 pharmaceutical products
- Real-world pricing ($1.75 - $9.50)
- Varying stock levels (0 - 350 units)
- Multiple batch lots per product
- Expiration dates 2025-2027

### Sales History
- Generated automatically on sale confirmation
- Unique invoice numbers (INV-YEAR-COUNTER)
- Complete transaction audit trail
- Pharmacist tracking

## 🚀 How to Use

### Navigate to POS
```dart
// From Dashboard or Products page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PharmacySalesPage()),
);
```

### Programmatic Cart Operations
```dart
// Access through SalesService singleton
final service = SalesService();
final products = service.getMockProducts();
final sales = service.getSalesHistory();
```

## 📱 Responsive Breakpoints

- **Desktop**: Full two-panel layout
- Layout is optimized for screens 1400px+ wide
- Minimum recommended width: 1200px

## 🔐 Permissions & Validations

- Pharmacy verification required for Rx sales
- Stock quantity controlled per lot
- Change calculation validation
- Cart non-empty requirement

## 📝 Technical Notes

- Uses `intl` package for date formatting
- State managed with `StateManagementProvider`
- Singleton service pattern for data
- Material 3 component library
- Null-safety throughout

## 📧 Support & Maintenance

For bug reports or feature requests, please add to issues with:
- Clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Screenshots if applicable

---

**Version**: 1.0.0  
**Last Updated**: February 15, 2026  
**Status**: Production Ready (Mock Data)
