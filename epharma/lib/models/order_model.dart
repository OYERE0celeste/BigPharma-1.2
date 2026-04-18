import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  enAttente,
  validee,
  enPreparation,
  enLivraison,
  livree,
  annulee;

  String get apiValue {
    switch (this) {
      case OrderStatus.enAttente:
        return 'en_attente';
      case OrderStatus.validee:
        return 'validee';
      case OrderStatus.enPreparation:
        return 'en_preparation';
      case OrderStatus.enLivraison:
        return 'en_livraison';
      case OrderStatus.livree:
        return 'livree';
      case OrderStatus.annulee:
        return 'annulee';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.enAttente:
        return 'En attente';
      case OrderStatus.validee:
        return 'Validée';
      case OrderStatus.enPreparation:
        return 'En préparation';
      case OrderStatus.enLivraison:
        return 'En livraison';
      case OrderStatus.livree:
        return 'Livrée';
      case OrderStatus.annulee:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.enAttente:
        return Colors.orange;
      case OrderStatus.validee:
        return Colors.blue;
      case OrderStatus.enPreparation:
        return Colors.deepPurple;
      case OrderStatus.enLivraison:
        return Colors.teal;
      case OrderStatus.livree:
        return Colors.green;
      case OrderStatus.annulee:
        return Colors.red;
    }
  }

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => OrderStatus.enAttente,
    );
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
      price: (json['price'] ?? 0).toDouble(),
      quantity: ((json['quantity'] ?? 0) as num).toInt(),
    );
  }
}

class OrderTimelineEntry {
  final String id;
  final OrderStatus status;
  final DateTime timestamp;
  final String userName;
  final String? note;

  const OrderTimelineEntry({
    required this.id,
    required this.status,
    required this.timestamp,
    required this.userName,
    this.note,
  });

  factory OrderTimelineEntry.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    return OrderTimelineEntry(
      id: (json['_id'] ?? '').toString(),
      status: OrderStatus.fromString(json['status']?.toString()),
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      userName: user is Map<String, dynamic>
          ? (user['fullName'] ?? 'N/A').toString()
          : 'N/A',
      note: json['note']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String userName;
  final String clientId;
  final String clientName;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final bool prescriptionRequired;
  final String? prescriptionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.prescriptionRequired,
    this.prescriptionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final client = json['clientId'];
    final user = json['userId'];
    final products =
        (json['products'] as List<dynamic>?) ??
        (json['items'] as List<dynamic>?) ??
        [];

    return OrderModel(
      id: (json['_id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      userId: user is Map<String, dynamic>
          ? (user['_id'] ?? '').toString()
          : (user ?? '').toString(),
      userName: user is Map<String, dynamic>
          ? (user['fullName'] ?? 'Inconnu').toString()
          : 'Inconnu',
      clientId: client is Map<String, dynamic>
          ? (client['_id'] ?? '').toString()
          : (client ?? '').toString(),
      clientName: client is Map<String, dynamic>
          ? (client['fullName'] ?? 'Inconnu').toString()
          : 'Inconnu',
      items: products
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] ?? json['total'] ?? 0).toDouble(),
      status: OrderStatus.fromString(json['status']?.toString()),
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

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  List<OrderStatus> get availableNextStatuses {
    switch (status) {
      case OrderStatus.enAttente:
        return [OrderStatus.validee, OrderStatus.annulee];
      case OrderStatus.validee:
        return [OrderStatus.enPreparation, OrderStatus.annulee];
      case OrderStatus.enPreparation:
        return [OrderStatus.enLivraison, OrderStatus.annulee];
      case OrderStatus.enLivraison:
        return [OrderStatus.livree, OrderStatus.annulee];
      case OrderStatus.livree:
      case OrderStatus.annulee:
        return [];
    }
  }
}
