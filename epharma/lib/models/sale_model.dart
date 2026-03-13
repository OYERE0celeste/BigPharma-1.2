import 'product_model.dart';

class CartItem {
  final Product product;
  final Lot selectedLot;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedLot,
    required this.quantity,
  });

  double get subtotal => product.sellingPrice * quantity;

  CartItem copyWith({Product? product, Lot? selectedLot, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      selectedLot: selectedLot ?? this.selectedLot,
      quantity: quantity ?? this.quantity,
    );
  }

  void getSubtotal() {}
}

class Sale {
  final String invoiceNumber;
  final DateTime dateTime;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final String pharmacistName;
  final bool prescriptionVerified;

  Sale({
    required this.invoiceNumber,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountReceived,
    required this.changeAmount,
    required this.pharmacistName,
    required this.prescriptionVerified,
  });

  Sale copyWith({
    String? invoiceNumber,
    DateTime? dateTime,
    List<CartItem>? items,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    String? paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? pharmacistName,
    bool? prescriptionVerified,
  }) {
    return Sale(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      pharmacistName: pharmacistName ?? this.pharmacistName,
      prescriptionVerified: prescriptionVerified ?? this.prescriptionVerified,
    );
  }
}
