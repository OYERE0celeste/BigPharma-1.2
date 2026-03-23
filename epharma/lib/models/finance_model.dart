/// Modèle de données pour les transactions financières
class FinanceTransactionModel {
  final String id;
  final DateTime dateTime;
  final String type;
  final String sourceModule;
  final String reference;
  final String description;
  final double amount;
  final bool isIncome;
  final String paymentMethod;
  final String employeeName;
  final String? saleId;
  final String? supplierOrderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FinanceTransactionModel({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.sourceModule,
    required this.reference,
    required this.description,
    required this.amount,
    required this.isIncome,
    required this.paymentMethod,
    required this.employeeName,
    this.saleId,
    this.supplierOrderId,
    this.createdAt,
    this.updatedAt,
  });

  factory FinanceTransactionModel.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'];
    double parsedAmount = 0.0;
    if (amountValue is int) {
      parsedAmount = amountValue.toDouble();
    } else if (amountValue is double)
      // ignore: curly_braces_in_flow_control_structures
      parsedAmount = amountValue;
    else if (amountValue is String)
      // ignore: curly_braces_in_flow_control_structures
      parsedAmount = double.tryParse(amountValue) ?? 0.0;

    final dateValue =
        json['dateTime'] ??
        json['createdAt'] ??
        DateTime.now().toIso8601String();

    return FinanceTransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      dateTime: DateTime.tryParse(dateValue.toString()) ?? DateTime.now(),
      type: json['type']?.toString() ?? 'other',
      sourceModule: json['sourceModule']?.toString() ?? 'Manual',
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: parsedAmount,
      isIncome:
          json['isIncome'] == true ||
          json['isIncome']?.toString().toLowerCase() == 'true',
      paymentMethod: json['paymentMethod']?.toString() ?? 'other',
      employeeName: json['employeeName']?.toString() ?? '',
      saleId: json['saleId']?.toString(),
      supplierOrderId: json['supplierOrderId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'sourceModule': sourceModule,
      'reference': reference,
      'description': description,
      'amount': amount,
      'isIncome': isIncome,
      'paymentMethod': paymentMethod,
      'employeeName': employeeName,
    };
    if (saleId != null) map['saleId'] = saleId as Object;
    if (supplierOrderId != null) map['supplierOrderId'] = supplierOrderId as Object;
    return map;
  }

  FinanceTransactionModel copyWith({
    String? id,
    DateTime? dateTime,
    String? type,
    String? sourceModule,
    String? reference,
    String? description,
    double? amount,
    bool? isIncome,
    String? paymentMethod,
    String? employeeName,
    String? saleId,
    String? supplierOrderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceTransactionModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      sourceModule: sourceModule ?? this.sourceModule,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      employeeName: employeeName ?? this.employeeName,
      saleId: saleId ?? this.saleId,
      supplierOrderId: supplierOrderId ?? this.supplierOrderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
