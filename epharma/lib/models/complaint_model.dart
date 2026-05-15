class ComplaintHistoryEntry {
  final String status;
  final String note;
  final String actorName;
  final DateTime createdAt;

  const ComplaintHistoryEntry({
    required this.status,
    required this.note,
    required this.actorName,
    required this.createdAt,
  });

  factory ComplaintHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ComplaintHistoryEntry(
      status: (json['status'] ?? 'en_attente').toString(),
      note: (json['note'] ?? '').toString(),
      actorName: (json['actorName'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class ComplaintModel {
  final String id;
  final String complaintNumber;
  final String category;
  final String subject;
  final String description;
  final String status;
  final String resolutionNote;
  final String clientName;
  final String invoiceNumber;
  final String orderNumber;
  final String productName;
  final DateTime createdAt;
  final List<ComplaintHistoryEntry> history;

  const ComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.resolutionNote,
    required this.clientName,
    required this.invoiceNumber,
    required this.orderNumber,
    required this.productName,
    required this.createdAt,
    required this.history,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final clientSnapshot =
        json['clientSnapshot'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final orderSnapshot =
        json['orderSnapshot'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final productSnapshot =
        json['productSnapshot'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final historyJson = (json['history'] as List<dynamic>? ?? []);

    return ComplaintModel(
      id: (json['_id'] ?? '').toString(),
      complaintNumber: (json['complaintNumber'] ?? '').toString(),
      category: (json['category'] ?? 'autre').toString(),
      subject: (json['subject'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'en_attente').toString(),
      resolutionNote: (json['resolutionNote'] ?? '').toString(),
      clientName: (clientSnapshot['fullName'] ?? 'Client').toString(),
      invoiceNumber: (orderSnapshot['invoiceNumber'] ?? '').toString(),
      orderNumber: (orderSnapshot['orderNumber'] ?? '').toString(),
      productName: (productSnapshot['name'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      history: historyJson
          .map(
            (item) =>
                ComplaintHistoryEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'resolue':
        return 'Résolue';
      case 'rejetee':
        return 'Rejetée';
      default:
        return status;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'produit_endommage':
        return 'Produit endommagé';
      case 'mauvaise_commande':
        return 'Mauvaise commande';
      case 'retard_livraison':
        return 'Retard de livraison';
      case 'produit_manquant':
        return 'Produit manquant';
      case 'erreur_facture':
        return 'Erreur facture';
      case 'probleme_utilisation':
        return 'Problème d’utilisation';
      default:
        return 'Autre';
    }
  }
}
