enum StockStatus { available, lowStock, outOfStock }

class Product {
  final String id;
  final String name;
  final double sellingPrice;
  final String category;
  final String description;
  final int stockQuantity;
  final int lowStockThreshold;
  final String image;
  final bool prescriptionRequired;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.category,
    required this.description,
    required this.stockQuantity,
    this.lowStockThreshold = 10,
    this.image = 'assets/images/placeholder.png',
    this.prescriptionRequired = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  StockStatus get stockStatus {
    if (stockQuantity <= 0) return StockStatus.outOfStock;
    if (stockQuantity <= lowStockThreshold) return StockStatus.lowStock;
    return StockStatus.available;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sellingPrice: (json['sellingPrice'] is num)
          ? (json['sellingPrice'] as num).toDouble()
          : double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      category: (json['category'] ?? 'Général').toString(),
      description: (json['description'] ?? '').toString(),
      stockQuantity: (json['stockQuantity'] is num)
          ? (json['stockQuantity'] as num).toInt()
          : int.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] is num)
          ? (json['lowStockThreshold'] as num).toInt()
          : int.tryParse(json['lowStockThreshold']?.toString() ?? '10') ?? 10,
      image: (json['image'] ?? 'assets/images/placeholder.png').toString(),
      prescriptionRequired: json['prescriptionRequired'] == true,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      reviewsCount: (json['reviewsCount'] is num) ? (json['reviewsCount'] as num).toInt() : 0,
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
      'image': image,
      'prescriptionRequired': prescriptionRequired,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }
}
