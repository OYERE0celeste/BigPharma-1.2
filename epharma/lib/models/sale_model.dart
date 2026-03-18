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

  Map<String, dynamic> toJson() {
    return {
      'product': product.id,
      'lotNumber': selectedLot.lotNumber,
      'expirationDate': selectedLot.expirationDate.toIso8601String(),
      'quantity': quantity,
      'unitPrice': product.sellingPrice,
      'total': subtotal,
    };
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final String lotNumber;
  final DateTime expirationDate;
  final int quantity;
  final double unitPrice;
  final double total;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.lotNumber,
    required this.expirationDate,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String productId = '';
    String productName = '';
    if (product is Map<String, dynamic>) {
      productId = product['_id']?.toString() ?? '';
      productName = product['name']?.toString() ?? '';
    } else {
      productId = product?.toString() ?? '';
      productName = json['productName']?.toString() ?? '';
    }

    return SaleItem(
      productId: productId,
      productName: productName,
      lotNumber: json['lotNumber']?.toString() ?? '',
      expirationDate: DateTime.tryParse(json['expirationDate']?.toString() ?? '') ?? DateTime.now(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      total: (json['total'] is num)
          ? (json['total'] as num).toDouble()
          : double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class Sale {
  final String id;
  final String invoiceNumber;
  final DateTime dateTime;
  final String client;
  final List<SaleItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final String pharmacist;
  final bool prescriptionVerified;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.dateTime,
    required this.client,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountReceived,
    required this.changeAmount,
    required this.pharmacist,
    required this.prescriptionVerified,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.tryParse(json['saleDate']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now();
    final clientData = json['client'];
    String clientName;
    if (clientData is Map<String, dynamic>) {
      clientName = clientData['fullName']?.toString() ?? clientData['_id']?.toString() ?? 'Client inconnu';
    } else {
      clientName = clientData?.toString() ?? 'Client inconnu';
    }
    final pharmacistData = json['pharmacist'];
    String pharmacistName;
    if (pharmacistData is Map<String, dynamic>) {
      pharmacistName = pharmacistData['name']?.toString() ?? pharmacistData['_id']?.toString() ?? 'Pharmacien inconnu';
    } else {
      pharmacistName = pharmacistData?.toString() ?? 'Pharmacien inconnu';
    }

    return Sale(
      id: json['_id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? json['_id']?.toString() ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: dateTime,
      client: clientName,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discountAmount: (json['discount'] is num)
          ? (json['discount'] as num).toDouble()
          : double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      taxAmount: (json['tax'] is num)
          ? (json['tax'] as num).toDouble()
          : double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      totalAmount: (json['total'] is num)
          ? (json['total'] as num).toDouble()
          : double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      amountReceived: (json['amountReceived'] is num)
          ? (json['amountReceived'] as num).toDouble()
          : double.tryParse(json['amountReceived']?.toString() ?? '0') ?? 0.0,
      changeAmount: (json['changeAmount'] is num)
          ? (json['changeAmount'] as num).toDouble()
          : double.tryParse(json['changeAmount']?.toString() ?? '0') ?? 0.0,
      pharmacist: pharmacistName,
      prescriptionVerified: json['prescriptionVerified'] == true,
    );
  }
}
