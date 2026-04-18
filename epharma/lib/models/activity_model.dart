import 'package:flutter/material.dart';

enum ActivityType {
  sale,
  return_,
  restocking,
  stockAdjustment,
  cancellation,
}

enum PaymentMethod { cash, card, check, transfer, other, mobileMoney }

enum TransactionStatus { completed, pending, cancelled, onHold }

class TransactionItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  TransactionItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

class ActivityModel {
  final String id;
  final DateTime dateTime;
  final ActivityType type;
  final String reference;
  final String clientOrSupplierName;
  final String productName;
  final int quantity;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String employeeName;
  final TransactionStatus status;
  final List<TransactionItem> listOfItems;
  final double taxAmount;
  final String notes;

  ActivityModel({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.reference,
    required this.clientOrSupplierName,
    required this.productName,
    required this.quantity,
    required this.totalAmount,
    required this.paymentMethod,
    required this.employeeName,
    required this.status,
    required this.listOfItems,
    required this.taxAmount,
    required this.notes,
  });

  String get typeLabel {
    switch (type) {
      case ActivityType.sale:
        return 'Vente';
      case ActivityType.return_:
        return 'Retour';
      case ActivityType.restocking:
        return 'Approvisionnement';
      case ActivityType.stockAdjustment:
        return 'Ajustement Stock';
      case ActivityType.cancellation:
        return 'Annulation';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.card:
        return 'Carte';
      case PaymentMethod.check:
        return 'Chèque';
      case PaymentMethod.transfer:
        return 'Virement';
      case PaymentMethod.other:
        return 'Autre';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ActivityType.sale:
        return Icons.shopping_cart;
      case ActivityType.return_:
        return Icons.assignment_return;
      case ActivityType.restocking:
        return Icons.add_business;
      case ActivityType.stockAdjustment:
        return Icons.settings_backup_restore;
      case ActivityType.cancellation:
        return Icons.cancel;
    }
  }

  Color get typeColor {
    switch (type) {
      case ActivityType.sale:
        return Colors.green;
      case ActivityType.return_:
        return Colors.orange;
      case ActivityType.restocking:
        return Colors.blue;
      case ActivityType.stockAdjustment:
        return Colors.teal;
      case ActivityType.cancellation:
        return Colors.red;
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.completed:
        return 'Terminé';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.cancelled:
        return 'Annulé';
      case TransactionStatus.onHold:
        return 'En pause';
    }
  }

  ActivityModel copyWith({
    String? id,
    DateTime? dateTime,
    ActivityType? type,
    String? reference,
    String? clientOrSupplierName,
    String? productName,
    int? quantity,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    String? employeeName,
    TransactionStatus? status,
    List<TransactionItem>? listOfItems,
    double? taxAmount,
    String? notes,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      clientOrSupplierName: clientOrSupplierName ?? this.clientOrSupplierName,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      listOfItems: listOfItems ?? this.listOfItems,
      taxAmount: taxAmount ?? this.taxAmount,
      notes: notes ?? this.notes,
    );
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['_id'] ?? json['id'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      type: _parseActivityType(json['type']),
      reference: json['reference'] ?? '',
      clientOrSupplierName: json['clientOrSupplierName'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      employeeName: json['employeeName'] ?? '',
      status: _parseTransactionStatus(json['status']),
      listOfItems: (json['listOfItems'] as List? ?? [])
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'type': type.name,
      'reference': reference,
      'clientOrSupplierName': clientOrSupplierName,
      'productName': productName,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'employeeName': employeeName,
      'status': status.name,
      'listOfItems': listOfItems.map((item) => item.toJson()).toList(),
      'taxAmount': taxAmount,
      'notes': notes,
    };
  }

  static ActivityType _parseActivityType(String? type) {
    return ActivityType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ActivityType.sale,
    );
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == method,
      orElse: () => PaymentMethod.other,
    );
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TransactionStatus.completed,
    );
  }
}
