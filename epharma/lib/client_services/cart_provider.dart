import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../client_models/order.dart';
import '../client_models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] ?? 1,
  );
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + (item.product.sellingPrice * item.quantity),
  );
  bool get requiresPrescription =>
      _items.any((item) => item.product.prescriptionRequired);

  List<OrderItem> get orderItems => _items
      .map(
        (item) => OrderItem(
          productId: item.product.id,
          name: item.product.name,
          price: item.product.sellingPrice,
          quantity: item.quantity,
        ),
      )
      .toList();

  CartProvider() {
    _loadFromPrefs();
  }

  void addItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _saveAndNotify();
  }

  void decrementItem(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      return;
    }

    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity--;
    }

    _saveAndNotify();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      return;
    }

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }

    _saveAndNotify();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveAndNotify();
  }

  void clear() {
    _items.clear();
    _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart_items', json.encode(data));
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cart_items');
      if (data != null) {
        final decoded = json.decode(data) as List<dynamic>;
        _items
          ..clear()
          ..addAll(
            decoded.map(
              (item) => CartItem.fromJson(item as Map<String, dynamic>),
            ),
          );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
}
