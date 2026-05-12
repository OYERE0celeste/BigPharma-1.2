class Product {
  final String id;
  final String name;
  final double sellingPrice;
  final String category;
  final String description;
  final int stockQuantity;
  final String image;


  const Product({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.category,
    required this.description,
    required this.stockQuantity,
    this.image = 'assets/images/placeholder.png',

  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      category: (json['category'] ?? 'Général').toString(),
      description: (json['description'] ?? '').toString(),
      stockQuantity: ((json['stockQuantity'] ?? 0) as num).toInt(),
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
      'image': image,

    };
  }
}
