import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../ventes/services/sales_api_service.dart';
import '../services/activity_service.dart';
//import '../services/finance_service.dart';
import '../models/activity_model.dart';
//import '../models/finance_model.dart';

class SalesProvider with ChangeNotifier {
  static const Duration _cacheDuration = Duration(minutes: 2);

  List<Sale> _sales = [];
  bool _isLoading = false;
  DateTime? _lastLoadedAt;
  Future<void>? _pendingLoad;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  double get totalRevenue =>
      _sales.fold(0.0, (sum, sale) => sum + (sale.totalAmount));
  int get totalSalesCount => _sales.length;

  void setProducts(List<Product> products) {
    notifyListeners();
  }

  bool get hasFreshData =>
      _sales.isNotEmpty &&
      _lastLoadedAt != null &&
      DateTime.now().difference(_lastLoadedAt!) < _cacheDuration;

  Future<void> loadSales({bool forceRefresh = false}) async {
    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (!forceRefresh && hasFreshData) {
      return;
    }

    final shouldShowLoader = _sales.isEmpty || forceRefresh;
    if (shouldShowLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _pendingLoad = _loadSalesInternal(shouldShowLoader: shouldShowLoader);
    return _pendingLoad!;
  }

  Future<void> _loadSalesInternal({required bool shouldShowLoader}) async {
    try {
      _sales = await SalesApiService.getSales();
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      debugPrint('SalesProvider Error: $e');
    } finally {
      _pendingLoad = null;
      if (shouldShowLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<Sale?> createSale({
    required List<CartItem> items,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required double amountReceived,
  }) async {
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    final sale = await SalesApiService.createSale(
      invoiceNumber: invoiceNumber,
      clientId: '000000000000000000000000',
      pharmacistId: '000000000000000000000000',
      cartItems: items,
      discount: discountAmount,
      tax: taxAmount,
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
    );

    if (sale != null) {
      _sales.insert(0, sale);
      _lastLoadedAt = DateTime.now();

      // Add activity
      final activity = ActivityModel(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        type: ActivityType.sale,
        reference: sale.invoiceNumber,
        clientOrSupplierName: sale.client,
        productName: items.map((i) => i.product.name).join(', '),
        quantity: items.fold(0, (sum, i) => sum + i.quantity),
        totalAmount: sale.totalAmount,
        paymentMethod: _mapPaymentMethod(paymentMethod),
        employeeName: sale.pharmacist,
        status: TransactionStatus.completed,
        listOfItems: items
            .map(
              (i) => TransactionItem(
                productName: i.product.name,
                quantity: i.quantity,
                unitPrice: i.product.sellingPrice,
                totalPrice: i.subtotal,
              ),
            )
            .toList(),
        taxAmount: sale.taxAmount,
        notes: 'Sale completed',
      );
      ActivityService.addActivity(activity);

      notifyListeners();
    }

    return sale;
  }

  PaymentMethod _mapPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'check':
        return PaymentMethod.check;
      case 'transfer':
        return PaymentMethod.transfer;
      default:
        return PaymentMethod.other;
    }
  }
}
