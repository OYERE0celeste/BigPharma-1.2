class ProductLookupResult {
  final String name;
  final String? brand;
  final String? description;
  final String? category;
  final String? imageUrl;
  final String? manufacturer;
  final String? dosage;
  final String? quantity;
  final String? ingredients;
  final String? externalId;
  final String source;
  final String? barcode;
  final Map<String, dynamic> rawData;

  ProductLookupResult({
    required this.name,
    this.brand,
    this.description,
    this.category,
    this.imageUrl,
    this.manufacturer,
    this.dosage,
    this.quantity,
    this.ingredients,
    this.externalId,
    required this.source,
    this.barcode,
    this.rawData = const {},
  });
}
