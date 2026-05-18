String orderStatusLabel(String status) {
  switch (status) {
    case 'en_attente':
      return 'En attente';
    case 'validee':
      return 'Validée';
    case 'en_preparation':
      return 'En préparation';
    case 'pret_pour_recuperation':
      return 'Prête pour récupération';
    case 'annulee':
      return 'Annulée';
    default:
      return status;
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final bool allowSubstitution;
  final String? substitutedWith;
  final String? substitutedName;
  final double? originalPrice;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.allowSubstitution = false,
    this.substitutedWith,
    this.substitutedName,
    this.originalPrice,
  });

  double get subtotal => price * quantity;
  bool get wasSubstituted => substitutedWith != null;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] ?? json['product'];
    final resolvedProductId = product is Map<String, dynamic>
        ? (product['_id'] ?? '').toString()
        : (product ?? '').toString();

    return OrderItem(
      productId: resolvedProductId,
      name: (json['name'] ?? '').toString(),
      price: ((json['price'] ?? 0) as num).toDouble(),
      quantity: ((json['quantity'] ?? 0) as num).toInt(),
      allowSubstitution: json['allowSubstitution'] == true,
      substitutedWith: json['substitutedWith']?.toString(),
      substitutedName: json['substitutedName']?.toString(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
    );
  }

  OrderItem copyWith({bool? allowSubstitution}) {
    return OrderItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity,
      allowSubstitution: allowSubstitution ?? this.allowSubstitution,
      substitutedWith: substitutedWith,
      substitutedName: substitutedName,
      originalPrice: originalPrice,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'allowSubstitution': allowSubstitution,
    };
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final String clientId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final String? collectionCode;
  final String pickupMode;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.clientId,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceNumber,
    this.invoiceDate,
    this.collectionCode,
    this.pickupMode = 'sur_place',
  });

  String get statusLabel => orderStatusLabel(status);
  bool get isTerminal => status == 'validee' || status == 'annulee';
  bool get hasInvoice => (invoiceNumber ?? '').trim().isNotEmpty;
  bool get hasSubstitutions => items.any((i) => i.wasSubstituted);

  factory Order.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    final client = json['clientId'];
    final products =
        (json['products'] as List<dynamic>?) ??
        (json['items'] as List<dynamic>?) ??
        [];

    return Order(
      id: (json['_id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      userId: user is Map<String, dynamic>
          ? (user['_id'] ?? '').toString()
          : (user ?? '').toString(),
      clientId: client is Map<String, dynamic>
          ? (client['_id'] ?? '').toString()
          : (client ?? '').toString(),
      items: products
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: ((json['totalPrice'] ?? json['total'] ?? 0) as num)
          .toDouble(),
      status: (json['status'] ?? 'en_attente').toString(),
      notes: json['notes']?.toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.tryParse(json['invoiceDate'].toString())
          : null,
      collectionCode: json['collectionCode']?.toString(),
      pickupMode: (json['pickupMode'] ?? 'sur_place').toString(),
    );
  }
}
