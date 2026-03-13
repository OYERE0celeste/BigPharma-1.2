enum StockStatus { available, lowStock, outOfStock }

enum LotStatus { active, expired, nearExpiration }

enum ProductStatus { active, discontinued }

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String supplier;
  final String barcode;
  final bool prescriptionRequired;
  final double purchasePrice;
  final double sellingPrice;
  final int lowStockThreshold;
  final List<Lot> lots;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.supplier,
    required this.barcode,
    required this.prescriptionRequired,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.lowStockThreshold,
    required this.lots,
  });

  int get totalStock => lots.fold<int>(0, (sum, lot) => sum + lot.quantity);

  int get availableStock =>
      lots.fold<int>(0, (sum, lot) => sum + lot.quantityAvailable);

  Lot? get nearestExpirationLot {
    if (lots.isEmpty) return null;
    final availableLots = lots.where((l) => l.quantityAvailable > 0).toList();
    if (availableLots.isEmpty) return null;
    availableLots.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    return availableLots.first;
  }

  StockStatus get stockStatus {
    final available = availableStock;
    if (available == 0) return StockStatus.outOfStock;
    if (available < lowStockThreshold) return StockStatus.lowStock;
    return StockStatus.available;
  }

  double get profitMargin =>
      ((sellingPrice - purchasePrice) / purchasePrice) * 100;

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? supplier,
    String? barcode,
    bool? prescriptionRequired,
    double? purchasePrice,
    double? sellingPrice,
    int? lowStockThreshold,
    List<Lot>? lots,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      barcode: barcode ?? this.barcode,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      lots: lots ?? this.lots,
    );
  }
}

class Lot {
  final String lotNumber;
  final DateTime manufacturingDate;
  final DateTime expirationDate;
  final int quantity;
  int quantityAvailable;
  final double costPrice;

  Lot({
    required this.lotNumber,
    required this.manufacturingDate,
    required this.expirationDate,
    required this.quantity,
    required this.quantityAvailable,
    required this.costPrice,
  });

  DateTime get expiration => expirationDate;

  LotStatus get status {
    final now = DateTime.now();
    if (expirationDate.isBefore(now)) return LotStatus.expired;
    if (expirationDate.difference(now).inDays <= 30) {
      return LotStatus.nearExpiration;
    }
    return LotStatus.active;
  }

  Lot copyWith({
    String? lotNumber,
    DateTime? manufacturingDate,
    DateTime? expirationDate,
    int? quantity,
    int? quantityAvailable,
    double? costPrice,
  }) {
    return Lot(
      lotNumber: lotNumber ?? this.lotNumber,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expirationDate: expirationDate ?? this.expirationDate,
      quantity: quantity ?? this.quantity,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      costPrice: costPrice ?? this.costPrice,
    );
  }
}
