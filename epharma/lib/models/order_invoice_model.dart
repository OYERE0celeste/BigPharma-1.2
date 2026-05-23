class OrderInvoiceItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  const OrderInvoiceItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory OrderInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return OrderInvoiceItemModel(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: ((json['quantity'] ?? 0) as num).toInt(),
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
    );
  }
}

class OrderInvoiceModel {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String orderNumber;
  final String orderId;
  final String collectionCode;
  final String pickupMode;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String orderStatus;
  final String orderStatusLabel;
  final String clientName;
  final String pharmacyName;
  final String pharmacyPhone;
  final List<OrderInvoiceItemModel> items;
  final double totalAmount;
  final double subtotal;
  final String currency;

  const OrderInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.orderNumber,
    required this.orderId,
    required this.collectionCode,
    required this.pickupMode,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.orderStatus,
    required this.orderStatusLabel,
    required this.clientName,
    required this.pharmacyName,
    required this.pharmacyPhone,
    required this.items,
    required this.totalAmount,
    required this.subtotal,
    required this.currency,
  });

  factory OrderInvoiceModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? const {};
    final pharmacy = json['pharmacy'] as Map<String, dynamic>? ?? const {};
    final items =
        (json['items'] as List<dynamic>? ?? const [])
            .map(
              (item) => OrderInvoiceItemModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

    return OrderInvoiceModel(
      id: (json['id'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      invoiceDate:
          DateTime.tryParse((json['invoiceDate'] ?? '').toString()) ??
          DateTime.now(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      collectionCode: (json['collectionCode'] ?? '').toString(),
      pickupMode: (json['pickupMode'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      paymentStatusLabel: (json['paymentStatusLabel'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? '').toString(),
      orderStatusLabel: (json['orderStatusLabel'] ?? '').toString(),
      clientName: (client['fullName'] ?? 'Client').toString(),
      pharmacyName:
          (pharmacy['name'] ?? 'PHARMACIE LA FLORALE').toString(),
      pharmacyPhone: (pharmacy['phone'] ?? '06 857 57 84').toString(),
      items: items,
      totalAmount: ((json['totalAmount'] ?? 0) as num).toDouble(),
      subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      currency: (json['currency'] ?? 'FCFA').toString(),
    );
  }
}
