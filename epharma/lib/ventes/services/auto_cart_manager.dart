// 🎮 Auto Cart Manager
// 
// Manages automatic product addition to cart when scan is detected on Sales page.
// 
// Responsibilities:
// - Listen to ProductFound events
// - Check if product already in cart
// - Add new product or increment quantity
// - Validate stock availability
// - Recalculate totals
// - Emit ProductAddedToCart event
// 
// Scope: Sales page only (context-aware)
// Lifecycle: Created when entering Sales page, disposed on exit

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import '../../scanner/services/scanner_event_bus.dart';

/// 🛒 Auto-add to cart manager
class AutoCartManager {
  /// Reference to cart items list (from PharmacySalesPage)
  final List<CartItem> cartItems;

  /// Callback when cart is modified
  final VoidCallback onCartChanged;

  /// Subscription to ProductFound events
  late final StreamSubscription<ProductFound> _productFoundSubscription;

  /// Event bus
  final ScannerEventBus _eventBus = ScannerEventBus();

  /// Create auto-cart manager
  /// 
  /// Parameters:
  /// - cartItems: Reference to the cart list from PharmacySalesPage
  /// - onCartChanged: Called when cart is modified (to trigger UI rebuild)
  AutoCartManager({
    required this.cartItems,
    required this.onCartChanged,
  }) {
    _init();
  }

  /// Initialize subscriptions
  void _init() {
    // Listen for ProductFound events
    _productFoundSubscription = _eventBus.on<ProductFound>().listen(
      _handleProductFound,
      onError: (error) {
        debugPrint('❌ Error in ProductFound handler: $error');
      },
    );

    debugPrint('✓ AutoCartManager initialized');
  }

  /// Handle product found event
  /// 
  /// Flow:
  /// 1. Check if product already in cart
  /// 2. If yes: increment quantity
  /// 3. If no: add as new item
  /// 4. Validate stock
  /// 5. Update cart
  /// 6. Emit event
  /// 7. Trigger UI update
  Future<void> _handleProductFound(ProductFound event) async {
    final product = event.product;
    final barcode = event.barcode;

    debugPrint('🛒 AutoCartManager: Handling ProductFound ($barcode)');

    try {
      // ========== STEP 1: CHECK IF ALREADY IN CART ==========

      final existingIndex = cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // ========== PRODUCT ALREADY IN CART: INCREMENT ==========

        final existingItem = cartItems[existingIndex];

        // Get available quantity from nearest expiration lot
        final availableLot = product.nearestExpirationLot;
        if (availableLot == null) {
          debugPrint('⚠️ No available lot for product: ${product.name}');
          _eventBus.emit(ScanError('No available stock for ${product.name}'));
          return;
        }

        // Check if we can increment
        final maxAvailable = availableLot.quantityAvailable;
        if (existingItem.quantity >= maxAvailable) {
          debugPrint(
              '⚠️ Cannot increment: Already at max (${existingItem.quantity}/$maxAvailable)');
          _eventBus.emit(
            ScanError('Max quantity reached for ${product.name}'),
          );
          return;
        }

        // Increment quantity
        final newQuantity = existingItem.quantity + 1;

        // Update the existing item
        cartItems[existingIndex] = CartItem(
          product: existingItem.product,
          selectedLot: availableLot,
          quantity: newQuantity,
        );

        debugPrint(
            '✓ Incremented: ${product.name} (qty: ${existingItem.quantity} → $newQuantity)');

        // Emit event
        _eventBus.emit(
          ProductAddedToCart(
            product,
            newQuantity,
            wasAlreadyInCart: true,
          ),
        );
      } else {
        // ========== NEW PRODUCT: ADD TO CART ==========

        final availableLot = product.nearestExpirationLot;
        if (availableLot == null) {
          debugPrint('⚠️ No available lot for new product: ${product.name}');
          _eventBus.emit(ProductNotFound(barcode));
          return;
        }

        if (availableLot.quantityAvailable <= 0) {
          debugPrint('⚠️ No stock available for: ${product.name}');
          _eventBus.emit(ScanError('No stock available for ${product.name}'));
          return;
        }

        // Create new cart item
        final newItem = CartItem(
          product: product,
          selectedLot: availableLot,
          quantity: 1,
        );

        cartItems.add(newItem);

        debugPrint('✓ Added to cart: ${product.name} (qty: 1)');

        // Emit event
        _eventBus.emit(
          ProductAddedToCart(
            product,
            1,
            wasAlreadyInCart: false,
          ),
        );
      }

      // ========== TRIGGER UI UPDATE ==========

      onCartChanged();
    } catch (e) {
      debugPrint('❌ Error adding product to cart: $e');
      _eventBus.emit(ScanError('Failed to add product: $e'));
    }
  }

  /// Get cart total
  double getCartTotal() {
    return cartItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  /// Get cart item count
  int getCartItemCount() {
    return cartItems.length;
  }

  /// Get total quantity of all items
  int getTotalQuantity() {
    return cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  /// Clear cart
  void clearCart() {
    cartItems.clear();
    onCartChanged();
  }

  /// Remove item from cart
  void removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      onCartChanged();
    }
  }

  /// Update item quantity
  void updateItemQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItems.length && newQuantity > 0) {
      final item = cartItems[index];
      cartItems[index] = CartItem(
        product: item.product,
        selectedLot: item.selectedLot,
        quantity: newQuantity,
      );
      onCartChanged();
    }
  }

  /// Get debug info
  String getDebugInfo() {
    return '''
AutoCartManager Status:
- Cart Items: ${cartItems.length}
- Total Quantity: ${getTotalQuantity()}
- Total: ${getCartTotal().toStringAsFixed(2)}
- Subscription Active: ${!_productFoundSubscription.isPaused}
''';
  }

  /// Dispose resources
  void dispose() {
    _productFoundSubscription.cancel();
    debugPrint('✓ AutoCartManager disposed');
  }
}
