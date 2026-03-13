import '../models/sale_model.dart';
import '../models/product_model.dart';

class SalesService {
  static final SalesService _instance = SalesService._internal();

  factory SalesService() {
    return _instance;
  }

  SalesService._internal();

  final List<Sale> _salesHistory = [];
  int _saleCounter = 1000;

  List<Product> getMockProducts() {
    // This should be replaced with actual product data from ProductProvider
    return [];
  }

  Sale createSale({
    required List<CartItem> items,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required double amountReceived,
    required bool prescriptionVerified,
  }) {
    final invoiceNumber = 'INV-${DateTime.now().year}-${_saleCounter++}';
    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final total = subtotal - discountAmount + taxAmount;
    final changeAmount = amountReceived - total;

    final sale = Sale(
      invoiceNumber: invoiceNumber,
      dateTime: DateTime.now(),
      items: items,
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      totalAmount: total,
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      pharmacistName: 'Pharmacist John Doe',
      prescriptionVerified: prescriptionVerified,
    );

    _salesHistory.add(sale);
    return sale;
  }

  List<Sale> getSalesHistory() => List.from(_salesHistory);

  List<Sale> filterSalesByDate(DateTime startDate, DateTime endDate) {
    return _salesHistory
        .where(
          (sale) =>
              sale.dateTime.isAfter(startDate) &&
              sale.dateTime.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<Sale> filterSalesByPaymentMethod(String method) {
    return _salesHistory.where((sale) => sale.paymentMethod == method).toList();
  }

  double getTotalRevenue() {
    return _salesHistory.fold(0.0, (sum, sale) => sum + sale.totalAmount);
  }

  int getTotalSalesCount() {
    return _salesHistory.length;
  }
}
