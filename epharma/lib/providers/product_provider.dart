import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/activity_service.dart';
import '../models/activity_model.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  int get outOfStockCount =>
      _products.where((p) => p.stockStatus == StockStatus.outOfStock).length;
  int get lowStockCount =>
      _products.where((p) => p.stockStatus == StockStatus.lowStock).length;
  int get totalProducts => _products.length;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _productService.getProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    await _productService.addProduct(product);
    await loadProducts();

    // Add activity
    final activity = ActivityModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      type: ActivityType.restocking,
      reference: product.id,
      clientOrSupplierName: product.supplier,
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
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    final product = _products.firstWhere((p) => p.id == id);
    await _productService.deleteProduct(id);
    await loadProducts();

    // Add activity
    final activity = ActivityModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      type: ActivityType.stockAdjustment,
      reference: product.id,
      clientOrSupplierName: product.supplier,
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
    await loadProducts();
  }

  Future<void> adjustStockQuantity(
    String productId,
    int quantity,
    String operation,
  ) async {
    await _productService.updateStockQuantity(productId, quantity, operation);
    await loadProducts();
  }
}
