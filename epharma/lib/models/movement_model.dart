class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String lotNumber;
  final String type;
  final int quantity;
  final int beforeQuantity;
  final int afterQuantity;
  final String reason;
  final String utilisateur;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.lotNumber,
    required this.type,
    required this.quantity,
    required this.beforeQuantity,
    required this.afterQuantity,
    required this.reason,
    required this.utilisateur,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    final produit = json['produitId'];
    return StockMovement(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: produit is Map<String, dynamic>
          ? produit['_id']?.toString() ?? produit['id']?.toString() ?? ''
          : json['produitId']?.toString() ?? '',
      productName: produit is Map<String, dynamic>
          ? produit['name']?.toString() ?? ''
          : '',
      lotNumber: json['lotNumber']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      quantity: int.tryParse(json['quantite']?.toString() ?? '') ?? 0,
      beforeQuantity:
          int.tryParse(json['beforeQuantity']?.toString() ?? '') ?? 0,
      afterQuantity: int.tryParse(json['afterQuantity']?.toString() ?? '') ?? 0,
      reason: json['reason']?.toString() ?? '',
      utilisateur: json['utilisateur']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
