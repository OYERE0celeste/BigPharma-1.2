import 'package:flutter/material.dart';

enum ActivityType {
  sale,
  return_,
  restocking,
  supplierPayment,
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
      case ActivityType.supplierPayment:
        return 'Paiement Fournisseur';
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
        // TODO: Handle this case.
        throw UnimplementedError();
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
      case ActivityType.supplierPayment:
        return Colors.purple;
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
}
