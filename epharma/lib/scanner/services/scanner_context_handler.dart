/// 🎯 Scanner Context Handler
///
/// Routes scanned products to appropriate handlers based on active page context.
/// Enables context-aware behavior:
/// - Sales page: Auto-add to cart
/// - Products page: Open details
/// - Dashboard: Show modal
///
/// Scope: Global
/// Lifecycle: Singleton, created once at app start
library;

import 'package:flutter/material.dart';
import 'scanner_event_bus.dart';
import '../../widgets/app_notification.dart';
import '../../products/widgets/product_detail.dart';

/// Represents the currently active page for scanner context
enum ScannerActivePageContext {
  sales, // PharmacySalesPage
  products, // PharmacyProductsPage
  dashboard, // Dashboard
  other, // Other pages
}

/// 🎯 Context handler for scanner events
class ScannerContextHandler {
  static final ScannerContextHandler _instance =
      ScannerContextHandler._internal();

  factory ScannerContextHandler() {
    return _instance;
  }

  static ScannerContextHandler get instance => _instance;

  ScannerContextHandler._internal() {
    // Subscribe to ProductFound events so routing happens automatically
    // even if pages don't individually subscribe to the event bus.
    try {
      ScannerEventBus.instance.on<ProductFound>().listen((event) {
        routeProductFound(event);
      });
      debugPrint('✓ ScannerContextHandler subscribed to ProductFound events');
    } catch (e) {
      debugPrint('❌ Failed to subscribe ScannerContextHandler: $e');
    }
  }

  /// Currently active page context
  ScannerActivePageContext _activePage = ScannerActivePageContext.other;

  /// Callbacks for products page context
  Function(ProductFound)? onProductsPageProductScanned;

  /// Callbacks for dashboard page context
  Function(ProductFound)? onDashboardProductScanned;

  /// Callbacks for other pages context
  Function(ProductFound)? onOtherPageProductScanned;

  // ========== PUBLIC API - HANDLER REGISTRATION ==========

  /// Register handler for Products page scan events
  ///
  /// Called by ProductsPage to receive ProductFound events
  void registerProductsPageHandler(Function(ProductFound) handler) {
    onProductsPageProductScanned = handler;
    debugPrint('✓ Products page handler registered');
  }

  /// Register handler for Dashboard page scan events
  ///
  /// Called by DashboardPage to receive ProductFound events
  void registerDashboardHandler(Function(ProductFound) handler) {
    onDashboardProductScanned = handler;
    debugPrint('✓ Dashboard handler registered');
  }

  /// Register handler for Other pages scan events
  ///
  /// Called by any other page to receive ProductFound events
  void registerOtherPageHandler(Function(ProductFound) handler) {
    onOtherPageProductScanned = handler;
    debugPrint('✓ Other page handler registered');
  }

  // ========== PUBLIC API - CONTEXT MANAGEMENT ==========

  /// Set active page context
  ///
  /// Call this when navigating to different pages
  /// to change scanner behavior
  void setActivePage(ScannerActivePageContext page) {
    if (_activePage != page) {
      debugPrint('📍 Scanner context changed: ${page.toString()}');
      _activePage = page;
    }
  }

  /// Get current active page context
  ScannerActivePageContext get activePage => _activePage;

  /// Get context name for debugging
  String getContextName() {
    switch (_activePage) {
      case ScannerActivePageContext.sales:
        return 'Sales';
      case ScannerActivePageContext.products:
        return 'Products';
      case ScannerActivePageContext.dashboard:
        return 'Dashboard';
      case ScannerActivePageContext.other:
        return 'Other';
    }
  }

  // ========== CONTEXT HANDLERS ==========

  /// Handle product scan on Sales page
  ///
  /// Auto-add to cart is handled by AutoCartManager
  /// listening to ProductFound event
  static void _handleSalesContext() {
    // AutoCartManager will handle the actual addition
    // via ProductFound event subscription
    debugPrint('💳 Scanner context: Sales - AutoCartManager will handle');
  }

  /// Handle product scan on Products page
  ///
  /// Opens product details modal
  void _handleProductsContext(ProductFound product) {
    debugPrint(
      '📋 Scanner context: Products - Opening details for ${product.product.name}',
    );

    // Call registered handler if available
    try {
      if (onProductsPageProductScanned != null) {
        onProductsPageProductScanned!.call(product);
      } else {
        // Fallback: open product details modal globally using navigatorKey
        final navigatorState = AppNotificationService.navigatorKey.currentState;
        debugPrint(
          'ScannerContextHandler: fallback open details — navigatorState: $navigatorState, product: ${product.product.name}',
        );
        if (navigatorState != null) {
          // Show a brief toast then push a fullscreen dialog route so it appears above overlays
          AppNotificationService.showInfo(
            'Ouverture fiche: ${product.product.name}',
          );
          Future.microtask(() {
            navigatorState.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ProductDetailsPanel(product: product.product),
              ),
            );
          });
        } else {
          AppNotificationService.showInfo('Scanné: ${product.product.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in products page handler: $e');
    }
  }

  /// Handle product scan on Dashboard
  ///
  /// Shows product modal
  void _handleDashboardContext(ProductFound product) {
    debugPrint(
      '📊 Scanner context: Dashboard - Showing modal for ${product.product.name}',
    );

    // Call registered handler if available
    try {
      if (onDashboardProductScanned != null) {
        onDashboardProductScanned!.call(product);
      } else {
        final navigatorState = AppNotificationService.navigatorKey.currentState;
        debugPrint(
          'ScannerContextHandler: fallback open details — navigatorState: $navigatorState, product: ${product.product.name}',
        );
        if (navigatorState != null) {
          AppNotificationService.showInfo(
            'Ouverture fiche: ${product.product.name}',
          );
          Future.microtask(() {
            navigatorState.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ProductDetailsPanel(product: product.product),
              ),
            );
          });
        } else {
          AppNotificationService.showInfo('Scanné: ${product.product.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in dashboard handler: $e');
    }
  }

  /// Handle product scan on other pages
  ///
  /// Shows generic product notification
  void _handleOtherContext(ProductFound product) {
    debugPrint(
      '❓ Scanner context: Other - Default handling for ${product.product.name}',
    );

    // Call registered handler if available
    try {
      if (onOtherPageProductScanned != null) {
        onOtherPageProductScanned!.call(product);
      } else {
        final navigatorState = AppNotificationService.navigatorKey.currentState;
        debugPrint(
          'ScannerContextHandler: fallback open details — navigatorState: $navigatorState, product: ${product.product.name}',
        );
        if (navigatorState != null) {
          AppNotificationService.showInfo(
            'Ouverture fiche: ${product.product.name}',
          );
          Future.microtask(() {
            navigatorState.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ProductDetailsPanel(product: product.product),
              ),
            );
          });
        } else {
          AppNotificationService.showInfo('Scanné: ${product.product.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in other page handler: $e');
    }
  }

  /// Get debug status
  String getDebugStatus() {
    return '''
Scanner Context Handler Status:
- Active Page: ${getContextName()}
- Page Value: ${_activePage.toString()}
- Products Handler: ${onProductsPageProductScanned != null ? '✓ Registered' : '✗ Not registered'}
- Dashboard Handler: ${onDashboardProductScanned != null ? '✓ Registered' : '✗ Not registered'}
- Other Handler: ${onOtherPageProductScanned != null ? '✓ Registered' : '✗ Not registered'}
''';
  }

  /// Route ProductFound event to appropriate context handler
  ///
  /// Called when ProductFound event is emitted
  /// Routes to appropriate handler based on current context
  void routeProductFound(ProductFound product) {
    switch (_activePage) {
      case ScannerActivePageContext.sales:
        // Sales page handled by AutoCartManager via event bus
        _handleSalesContext();
        break;
      case ScannerActivePageContext.products:
        _handleProductsContext(product);
        break;
      case ScannerActivePageContext.dashboard:
        _handleDashboardContext(product);
        break;
      case ScannerActivePageContext.other:
        _handleOtherContext(product);
        break;
    }
  }
}
