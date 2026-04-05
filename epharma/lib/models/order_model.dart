import 'package:intl/intl.dart';

enum OrderStatus {
  pending,
  validated,
  preparing,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.validated:
        return 'Validée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String pId = "";
    if (product is Map) {
      pId = product['_id'] ?? "";
    } else {
      pId = product?.toString() ?? "";
    }

    return OrderItem(
      productId: pId,
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'subtotal': subtotal,
      };
}

class OrderTimelineEntry {
  final String id;
  final OrderStatus status;
  final DateTime timestamp;
  final String userName;
  final String? note;

  OrderTimelineEntry({
    required this.id,
    required this.status,
    required this.timestamp,
    required this.userName,
    this.note,
  });

  factory OrderTimelineEntry.fromJson(Map<String, dynamic> json) {
    return OrderTimelineEntry(
      id: json['_id'] ?? '',
      status: OrderStatus.fromString(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      userName: json['userId'] is Map ? (json['userId']['fullName'] ?? 'N/A') : 'N/A',
      note: json['note'],
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String clientId;
  final String clientName;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final String createdByName;
  final String? notes;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.total,
    required this.status,
    required this.createdByName,
    this.notes,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'];
    String cId = "";
    String cName = "Inconnu";
    if (client is Map) {
      cId = client['_id'] ?? "";
      cName = client['fullName'] ?? "Inconnu";
    } else {
      cId = client?.toString() ?? "";
    }

    final creator = json['createdBy'];
    String creatorName = "Inconnu";
    if (creator is Map) {
      creatorName = creator['fullName'] ?? "Inconnu";
    }

    return OrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      clientId: cId,
      clientName: cName,
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.fromString(json['status']),
      createdByName: creatorName,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
}
