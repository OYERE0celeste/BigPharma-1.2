class InvoiceParty {
  final String fullName;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;

  const InvoiceParty({
    this.fullName = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.country = '',
  });

  factory InvoiceParty.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return InvoiceParty(
      fullName: (data['fullName'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      country: (data['country'] ?? '').toString(),
    );
  }

  String get displayName => fullName.isNotEmpty ? fullName : name;
}

class InvoiceItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: ((json['quantity'] ?? 0) as num).toInt(),
      unitPrice: ((json['unitPrice'] ?? json['price'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? json['totalPrice'] ?? 0) as num).toDouble(),
    );
  }
}

class InvoiceRecord {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String orderId;
  final String orderNumber;
  final String collectionCode;
  final String pickupMode;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String orderStatus;
  final String orderStatusLabel;
  final InvoiceParty client;
  final InvoiceParty pharmacy;
  final List<InvoiceItem> items;
  final double subtotal;
  final double totalAmount;
  final String currency;

  const InvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.orderId,
    required this.orderNumber,
    required this.collectionCode,
    required this.pickupMode,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.orderStatus,
    required this.orderStatusLabel,
    required this.client,
    required this.pharmacy,
    required this.items,
    required this.subtotal,
    required this.totalAmount,
    this.currency = 'FCFA',
  });

  factory InvoiceRecord.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    return InvoiceRecord(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      invoiceDate:
          DateTime.tryParse((json['invoiceDate'] ?? '').toString()) ??
          DateTime.now(),
      orderId: (json['orderId'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      collectionCode: (json['collectionCode'] ?? '').toString(),
      pickupMode: (json['pickupMode'] ?? 'sur_place').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'en_attente').toString(),
      paymentStatusLabel: (json['paymentStatusLabel'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? 'en_attente').toString(),
      orderStatusLabel: (json['orderStatusLabel'] ?? '').toString(),
      client: InvoiceParty.fromJson(json['client'] as Map<String, dynamic>?),
      pharmacy: InvoiceParty.fromJson(
        json['pharmacy'] as Map<String, dynamic>?,
      ),
      items: itemsJson
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: ((json['subtotal'] ?? json['totalAmount'] ?? 0) as num)
          .toDouble(),
      totalAmount: ((json['totalAmount'] ?? 0) as num).toDouble(),
      currency: (json['currency'] ?? 'FCFA').toString(),
    );
  }

  bool get hasCollectionCode => collectionCode.trim().isNotEmpty;
  bool get isPickup => pickupMode == 'sur_place';
}
