enum StockStatus { available, lowStock, outOfStock }

enum LotStatus { active, expired, nearExpiration }

enum ProductStatus { active, discontinued }

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String description;
  final String supplier;
  final String barcode;
  final bool prescriptionRequired;
  final double purchasePrice;
  final double sellingPrice;
  final int lowStockThreshold;
  final List<Lot> lots;
  final String expirationStatus;

  Product({
    required this.id,
    required this.name,
    this.sku = '',
    required this.category,
    required this.description,
    required this.supplier,
    required this.barcode,
    required this.prescriptionRequired,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.lowStockThreshold,
    required this.lots,
    this.expirationStatus = 'OK',
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
    String? sku,
    String? category,
    String? description,
    String? supplier,
    String? barcode,
    bool? prescriptionRequired,
    double? purchasePrice,
    double? sellingPrice,
    int? lowStockThreshold,
    List<Lot>? lots,
    String? expirationStatus,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      barcode: barcode ?? this.barcode,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      lots: lots ?? this.lots,
      expirationStatus: expirationStatus ?? this.expirationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'supplier': supplier,
      'barcode': barcode,
      'prescriptionRequired': prescriptionRequired,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'lowStockThreshold': lowStockThreshold,
      'lots': lots.map((lot) => lot.toJson()).toList(),
      'expirationStatus': expirationStatus,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      prescriptionRequired: json['prescriptionRequired'] == true,
      purchasePrice: (json['purchasePrice'] is num)
          ? (json['purchasePrice'] as num).toDouble()
          : double.tryParse(json['purchasePrice']?.toString() ?? '0') ?? 0.0,
      sellingPrice: (json['sellingPrice'] is num)
          ? (json['sellingPrice'] as num).toDouble()
          : double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      lowStockThreshold:
          int.tryParse(json['lowStockThreshold']?.toString() ?? '0') ?? 0,
      lots:
          (json['lots'] as List<dynamic>?)
              ?.map((e) => Lot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expirationStatus: json['expirationStatus']?.toString() ?? 'OK',
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

  Map<String, dynamic> toJson() {
    return {
      'lotNumber': lotNumber,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'quantity': quantity,
      'quantityAvailable': quantityAvailable,
      'costPrice': costPrice,
    };
  }

  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      lotNumber: json['lotNumber']?.toString() ?? '',
      manufacturingDate:
          DateTime.tryParse(json['manufacturingDate']?.toString() ?? '') ??
          DateTime.now(),
      expirationDate:
          DateTime.tryParse(json['expirationDate']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 365)),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      quantityAvailable:
          int.tryParse(json['quantityAvailable']?.toString() ?? '0') ?? 0,
      costPrice: (json['costPrice'] is num)
          ? (json['costPrice'] as num).toDouble()
          : double.tryParse(json['costPrice']?.toString() ?? '0') ?? 0.0,
    );
  }

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
