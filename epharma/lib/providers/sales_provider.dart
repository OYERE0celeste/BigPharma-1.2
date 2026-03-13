import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../services/sales_service.dart';
import '../services/activity_service.dart';
import '../services/finance_service.dart';
import '../models/activity_model.dart';
import '../models/finance_model.dart';

class SalesProvider with ChangeNotifier {
  final SalesService _salesService = SalesService();
  final FinanceService _financeService = FinanceService();

  List<Sale> _sales = [];

  List<Sale> get sales => _sales;
  double get totalRevenue => _salesService.getTotalRevenue();
  int get totalSalesCount => _salesService.getTotalSalesCount();

  void setProducts(List<Product> products) {
    notifyListeners();
  }

  Sale createSale({
    required List<CartItem> items,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required double amountReceived,
    required bool prescriptionVerified,
  }) {
    final sale = _salesService.createSale(
      items: items,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      prescriptionVerified: prescriptionVerified,
    );

    _sales = _salesService.getSalesHistory();

    // Deduct stock
    // ignore: unused_local_variable
    for (final item in items) {
      // This should be handled by ProductProvider, but for now we'll assume it's updated externally
    }

    // Add activity
    final activity = ActivityModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      type: ActivityType.sale,
      reference: sale.invoiceNumber,
      clientOrSupplierName: 'Customer',
      productName: items.map((i) => i.product.name).join(', '),
      quantity: items.fold(0, (sum, i) => sum + i.quantity),
      totalAmount: sale.totalAmount,
      paymentMethod: _mapPaymentMethod(paymentMethod),
      employeeName: sale.pharmacistName,
      status: TransactionStatus.completed,
      listOfItems: items.map((i) => TransactionItem(
        productName: i.product.name,
        quantity: i.quantity,
        unitPrice: i.product.sellingPrice,
        totalPrice: i.subtotal,
      )).toList(),
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
      employeeName: sale.pharmacistName,
    );
    _financeService.addTransaction(financeTransaction);

    notifyListeners();
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

  List<Sale> getSalesHistory() => _salesService.getSalesHistory();
}