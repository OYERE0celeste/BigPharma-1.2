import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/activity_service.dart';
import '../models/activity_model.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  static const Duration _cacheDuration = Duration(minutes: 2);

  List<Product> _products = [];
  bool _isLoading = false;
  DateTime? _lastLoadedAt;
  Future<void>? _pendingLoad;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  int get outOfStockCount =>
      _products.where((p) => p.stockStatus == StockStatus.outOfStock).length;
  int get lowStockCount =>
      _products.where((p) => p.stockStatus == StockStatus.lowStock).length;
  int get expiredCount =>
      _products.where((p) => p.expirationStatus == 'EXPIRÉ').length;
  int get nearExpirationCount =>
      _products.where((p) => p.expirationStatus == 'BIENTÔT EXPIRÉ').length;
  int get totalProducts => _products.length;

  bool get hasFreshData =>
      _products.isNotEmpty &&
      _lastLoadedAt != null &&
      DateTime.now().difference(_lastLoadedAt!) < _cacheDuration;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (!forceRefresh && hasFreshData) {
      return;
    }

    final shouldShowLoader = _products.isEmpty;
    if (shouldShowLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _pendingLoad = _loadProductsInternal(shouldShowLoader: shouldShowLoader);
    return _pendingLoad!;
  }

  Future<void> _loadProductsInternal({required bool shouldShowLoader}) async {
    try {
      _products = await _productService.getProducts();
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      debugPrint('ProductProvider Error: $e');
    } finally {
      _pendingLoad = null;
      if (shouldShowLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    await _productService.addProduct(product);
    _lastLoadedAt = null;
    await loadProducts(forceRefresh: true);

    // Add activity
    final activity = ActivityModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      type: ActivityType.restocking,
      reference: product.id,
      clientOrSupplierName: 'Inventaire',
      productName: product.name,
      quantity: product.totalStock,
      totalAmount: product.purchasePrice * product.totalStock,
      paymentMethod: PaymentMethod.other,
      employeeName: 'System',
      status: TransactionStatus.completed,
      listOfItems: [
        TransactionItem(
          productName: product.name,
          quantity: product.totalStock,
          unitPrice: product.purchasePrice,
          totalPrice: product.purchasePrice * product.totalStock,
        ),
      ],
      taxAmount: 0,
      notes: 'Product added to inventory',
    );
    ActivityService.addActivity(activity);
  }

  Future<void> updateProduct(Product product) async {
    await _productService.updateProduct(product);
    _lastLoadedAt = null;
    await loadProducts(forceRefresh: true);
  }

  Future<void> deleteProduct(String id) async {
    final product = _products.firstWhere((p) => p.id == id);
    await _productService.deleteProduct(id);
    _lastLoadedAt = null;
    await loadProducts(forceRefresh: true);

    // Add activity
    final activity = ActivityModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      type: ActivityType.stockAdjustment,
      reference: product.id,
      clientOrSupplierName: 'Inventaire',
      productName: product.name,
      quantity: -product.totalStock,
      totalAmount: 0,
      paymentMethod: PaymentMethod.other,
      employeeName: 'System',
      status: TransactionStatus.completed,
      listOfItems: [],
      taxAmount: 0,
      notes: 'Product deleted from inventory',
    );
    ActivityService.addActivity(activity);
  }

  Future<void> updateStock(
    String productId,
    String lotNumber,
    int quantityChange,
  ) async {
    await _productService.updateStock(productId, lotNumber, quantityChange);
    _lastLoadedAt = null;
    await loadProducts(forceRefresh: true);
  }

  Future<void> adjustStockQuantity(
    String productId,
    int quantity,
    String operation,
  ) async {
    await _productService.updateStockQuantity(productId, quantity, operation);
    _lastLoadedAt = null;
    await loadProducts(forceRefresh: true);
  }
}
