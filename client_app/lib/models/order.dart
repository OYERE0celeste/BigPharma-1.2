String orderStatusLabel(String status) {
  switch (status) {
    case 'en_attente':
      return 'En attente';
    case 'en_preparation':
      return 'En préparation';
    case 'pret_pour_recuperation':
      return 'Prête (à récupérer)';
    case 'validee':
      return 'Récupérée';
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

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] ?? json['product'];
    final resolvedProductId = product is Map<String, dynamic>
        ? (product['_id'] ?? '').toString()
        : (product ?? '').toString();

    return OrderItem(
      productId: resolvedProductId,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {'productId': productId, 'quantity': quantity};
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
  final bool prescriptionRequired;
  final String? prescriptionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.clientId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.prescriptionRequired,
    this.prescriptionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel => orderStatusLabel(status);
  bool get isTerminal => status == 'validee' || status == 'annulee';

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
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : (json['total'] is num)
              ? (json['total'] as num).toDouble()
              : double.tryParse((json['totalPrice'] ?? json['total'] ?? '0').toString()) ?? 0.0,
      status: (json['status'] ?? 'en_attente').toString(),
      prescriptionRequired: json['prescriptionRequired'] == true,
      prescriptionId: json['prescriptionId']?.toString(),
      notes: json['notes']?.toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
