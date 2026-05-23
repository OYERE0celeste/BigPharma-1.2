/// 📋 CONTEXT HANDLERS INTEGRATION GUIDE
///
/// This document shows how to integrate scanner context handlers
/// in ProductsPage and DashboardPage

// ============================================================================
// EXAMPLE 1: ProductsPage Integration
// ============================================================================

/*
In lib/produits/pharmacy_products_page.dart:

import 'package:flutter/material.dart';
import '../scanner/services/scanner_context_handler.dart';
import '../scanner/services/scanner_event_bus.dart';

class PharmacyProductsPage extends StatefulWidget {
  const PharmacyProductsPage({super.key});

  @override
  State<PharmacyProductsPage> createState() => _PharmacyProductsPageState();
}

class _PharmacyProductsPageState extends State<PharmacyProductsPage> {
  late final StreamSubscription _productFoundSubscription;

  @override
  void initState() {
    super.initState();

    // 1️⃣ SET CONTEXT: Tell scanner system we're on Products page
    ScannerContextHandler.instance
        .setActivePage(ScannerActivePageContext.products);

    // 2️⃣ REGISTER HANDLER: When product is scanned, open details
    ScannerContextHandler.instance.registerProductsPageHandler(
      (ProductFound event) {
        _openProductDetails(event.product);
      },
    );

    // 3️⃣ OPTIONAL: Also listen directly to events if needed
    _productFoundSubscription =
        ScannerEventBus().on<ProductFound>().listen((event) {
      // This gives you fine-grained control
      // but the registered handler above is called first
    });
  }

  @override
  void dispose() {
    _productFoundSubscription.cancel();
    super.dispose();
  }

  /// Open product details when scanned
  void _openProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailsDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: const Center(child: Text('Products list here')),
    );
  }
}
*/

// ============================================================================
// EXAMPLE 2: DashboardPage Integration
// ============================================================================

/*
In lib/dashboard/dashboard_page.dart:

import 'package:flutter/material.dart';
import '../scanner/services/scanner_context_handler.dart';
import '../scanner/services/scanner_event_bus.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    // 1️⃣ SET CONTEXT: Tell scanner system we're on Dashboard
    ScannerContextHandler.instance
        .setActivePage(ScannerActivePageContext.dashboard);

    // 2️⃣ REGISTER HANDLER: When product is scanned, show summary
    ScannerContextHandler.instance.registerDashboardHandler(
      (ProductFound event) {
        _showProductSummary(event.product);
      },
    );
  }

  /// Show quick product summary
  void _showProductSummary(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: ${product.name} - ${product.stock} in stock'),
        duration: const Duration(seconds: 3),
      ),
    );

    // Or show a modal
    showModalBottomSheet(
      context: context,
      builder: (_) => ProductSummaryModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: const Center(child: Text('Dashboard content here')),
    );
  }
}
*/

// ============================================================================
// EXAMPLE 3: Generic Page Integration (Other Context)
// ============================================================================

/*
For any other page that wants to handle scanned products:

import '../scanner/services/scanner_context_handler.dart';

@override
void initState() {
  super.initState();

  // SET CONTEXT
  ScannerContextHandler.instance
      .setActivePage(ScannerActivePageContext.other);

  // REGISTER HANDLER
  ScannerContextHandler.instance.registerOtherPageHandler(
    (ProductFound event) {
      // Do something with the scanned product
      print('Scanned in generic page: ${event.product.name}');
    },
  );
}
*/

// ============================================================================
// HOW IT WORKS
// ============================================================================

/*
FLOW:

1. User navigates to ProductsPage
   └─ initState() is called
   └─ setActivePage(products) is called
   └─ registerProductsPageHandler() is called
   └─ Handler function stored in ScannerContextHandler

2. User scans a barcode
   └─ GlobalKeyboardScannerService receives input
   └─ Validates barcode format
   └─ Looks up product via API
   └─ Emits ProductFound event via ScannerEventBus

3. ProductFound event is received
   └─ Pages listening to ProductFound event are notified
   └─ ScannerContextHandler.routeProductFound() is called
   └─ Current context is checked (products page)
   └─ Registered handler for products page is called
   └─ Handler opens product details modal

4. User closes modal or navigates away
   └─ dispose() is called on previous page
   └─ New page takes over
   └─ New page registers its own handler
*/

// ============================================================================
// QUICK TEMPLATE
// ============================================================================

/*
Copy this template for adding scanner support to any page:

import '../scanner/services/scanner_context_handler.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();

    // Set this page as active for scanner
    ScannerContextHandler.instance
        .setActivePage(ScannerActivePageContext.other);

    // Register handler for scanned products
    ScannerContextHandler.instance.registerOtherPageHandler(
      (ProductFound event) {
        // Handle scanned product
        _handleScannedProduct(event.product);
      },
    );
  }

  void _handleScannedProduct(Product product) {
    // Your logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your UI here
    );
  }
}
*/

// ============================================================================
// DEBUG: Check Handler Status
// ============================================================================

/*
To verify handlers are registered:

// In any page or debug widget:
print(ScannerContextHandler.instance.getDebugStatus());

// Output example:
// Scanner Context Handler Status:
// - Active Page: Products
// - Page Value: ScannerActivePageContext.products
// - Products Handler: ✓ Registered
// - Dashboard Handler: ✗ Not registered
// - Other Handler: ✗ Not registered
*/

// ============================================================================
// NOTES
// ============================================================================

/*
IMPORTANT:
- Only ONE handler can be active at a time (current page)
- ProductFound event is ALWAYS emitted to ScannerEventBus (all listeners get it)
- The registered handler adds context-aware behavior on top
- Sales page doesn't need a registered handler (AutoCartManager handles it)

WHEN TO USE REGISTERED HANDLER:
- When you want page-specific behavior for scanned products
- Example: ProductsPage opens details modal
- Example: DashboardPage shows summary notification

WHEN TO USE DIRECT EVENT LISTENING:
- When you want to listen on multiple pages simultaneously
- When you want global behavior regardless of context
- Example: Log all scans to analytics

YOU CAN USE BOTH:
- Registered handler for primary behavior
- Direct event listening for secondary behavior (logging, etc.)
*/
