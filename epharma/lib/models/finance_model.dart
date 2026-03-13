/// Modèle de données pour les transactions financières
class FinanceTransactionModel {
  final String id;
  final DateTime dateTime;
  final String
  type; // 'Vente', 'Paiement fournisseur', 'Dépense', 'Retour', etc.
  final String sourceModule; // 'Ventes', 'Stocks', 'Commandes', 'Registre'
  final String reference; // Numéro de facture, commande, etc.
  final String description;
  final double amount;
  final bool isIncome; // true pour revenus, false pour dépenses
  final String paymentMethod; // 'Espèces', 'Carte', 'Virement', etc.
  final String employeeName;
  final String? relatedTransactionId; // ID de transaction liée si applicable

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
    this.relatedTransactionId,
  });

  // Factory pour créer depuis JSON (pour intégration backend future)
  factory FinanceTransactionModel.fromJson(Map<String, dynamic> json) {
    return FinanceTransactionModel(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      sourceModule: json['sourceModule'],
      reference: json['reference'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      isIncome: json['isIncome'],
      paymentMethod: json['paymentMethod'],
      employeeName: json['employeeName'],
      relatedTransactionId: json['relatedTransactionId'],
    );
  }

  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'sourceModule': sourceModule,
      'reference': reference,
      'description': description,
      'amount': amount,
      'isIncome': isIncome,
      'paymentMethod': paymentMethod,
      'employeeName': employeeName,
      'relatedTransactionId': relatedTransactionId,
    };
  }

  // Copie avec modifications
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
    String? relatedTransactionId,
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
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
    );
  }
}
