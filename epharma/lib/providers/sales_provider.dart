import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../ventes/services/sales_api_service.dart';
import '../activites/services/activity_service.dart';
import '../services/finance_service.dart';
import '../models/activity_model.dart';
import '../models/finance_model.dart';

class SalesProvider with ChangeNotifier {
  final FinanceService _financeService = FinanceService();

  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  double get totalRevenue =>
      _sales.fold(0.0, (sum, sale) => sum + (sale.totalAmount));
  int get totalSalesCount => _sales.length;

  void setProducts(List<Product> products) {
    notifyListeners();
  }

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sales = await SalesApiService.getSales();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Sale?> createSale({
    required List<CartItem> items,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required double amountReceived,
    required bool prescriptionVerified,
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
      prescriptionVerified: prescriptionVerified,
    );

    if (sale != null) {
      _sales.insert(0, sale);

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

      // Add finance transaction
      final financeTransaction = FinanceTransactionModel(
        id: 'FIN-${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        type: 'Vente',
        sourceModule: 'Ventes',
        reference: sale.invoiceNumber,
        description: 'Sale of ${items.length} items',
        amount: sale.totalAmount,
        isIncome: true,
        paymentMethod: paymentMethod,
        employeeName: sale.pharmacist,
      );
      _financeService.addTransaction(financeTransaction);

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
