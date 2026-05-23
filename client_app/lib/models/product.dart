enum ProductStockStatus { inStock, lowStock, outOfStock }

class ProductLot {
  final int quantityAvailable;

  const ProductLot({required this.quantityAvailable});

  factory ProductLot.fromJson(Map<String, dynamic> json) {
    return ProductLot(
      quantityAvailable:
          int.tryParse(json['quantityAvailable']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'quantityAvailable': quantityAvailable};
  }
}

class Product {
  final String id;
  final String name;
  final double sellingPrice;
  final String category;
  final String description;
  final int stockQuantity;
  final int lowStockThreshold;
  final int minStockLevel;
  final ProductStockStatus? apiStockStatus;
  final List<ProductLot> lots;
  final String image;

  const Product({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.category,
    required this.description,
    required this.stockQuantity,
    this.lowStockThreshold = 0,
    this.minStockLevel = 0,
    this.apiStockStatus,
    this.lots = const [],
    this.image = 'assets/images/placeholder.png',
  });

  int get availableStock {
    if (lots.isNotEmpty) {
      return lots.fold<int>(0, (sum, lot) => sum + lot.quantityAvailable);
    }
    return stockQuantity;
  }

  int get effectiveLowStockThreshold {
    if (lowStockThreshold > 0) return lowStockThreshold;
    return minStockLevel;
  }

  ProductStockStatus get stockStatus {
    if (apiStockStatus != null) {
      return apiStockStatus!;
    }

    final available = availableStock;
    if (available <= 0) return ProductStockStatus.outOfStock;

    final threshold = effectiveLowStockThreshold;
    if (threshold > 0 && available <= threshold) {
      return ProductStockStatus.lowStock;
    }

    return ProductStockStatus.inStock;
  }

  bool get isOutOfStock => stockStatus == ProductStockStatus.outOfStock;
  bool get isLowStock => stockStatus == ProductStockStatus.lowStock;
  bool get isInStock => stockStatus == ProductStockStatus.inStock;

  String get stockStatusLabel {
    switch (stockStatus) {
      case ProductStockStatus.inStock:
        return 'En stock';
      case ProductStockStatus.lowStock:
        return 'Stock faible';
      case ProductStockStatus.outOfStock:
        return 'Rupture';
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sellingPrice: (json['sellingPrice'] as num? ?? 0).toDouble(),
      category: (json['category'] ?? 'General').toString(),
      description: (json['description'] ?? '').toString(),
      stockQuantity:
          int.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,
      lowStockThreshold:
          int.tryParse(json['lowStockThreshold']?.toString() ?? '0') ?? 0,
      minStockLevel:
          int.tryParse(json['minStockLevel']?.toString() ?? '0') ?? 0,
      apiStockStatus: _parseStockStatus(json['stockStatus']?.toString()),
      lots:
          (json['lots'] as List<dynamic>?)
              ?.map((lot) => ProductLot.fromJson(lot as Map<String, dynamic>))
              .toList() ??
          const [],
      image: (json['image'] ?? 'assets/images/placeholder.png').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sellingPrice': sellingPrice,
      'category': category,
      'description': description,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'minStockLevel': minStockLevel,
      'stockStatus': _stockStatusToApiValue(apiStockStatus ?? stockStatus),
      'lots': lots.map((lot) => lot.toJson()).toList(),
      'image': image,
    };
  }

  static ProductStockStatus? _parseStockStatus(String? value) {
    switch (value) {
      case 'in_stock':
        return ProductStockStatus.inStock;
      case 'low_stock':
        return ProductStockStatus.lowStock;
      case 'out_of_stock':
        return ProductStockStatus.outOfStock;
      default:
        return null;
    }
  }

  static String _stockStatusToApiValue(ProductStockStatus value) {
    switch (value) {
      case ProductStockStatus.inStock:
        return 'in_stock';
      case ProductStockStatus.lowStock:
        return 'low_stock';
      case ProductStockStatus.outOfStock:
        return 'out_of_stock';
    }
  }
}
