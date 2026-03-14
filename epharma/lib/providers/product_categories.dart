class ProductCategory {
  final String value;
  final String label;

  const ProductCategory(this.value, this.label);

  @override
  String toString() => label;
}

const List<ProductCategory> productCategories = [
  ProductCategory('analgesique', 'Analgesique (Pain relief)'),
  ProductCategory('antibiotique', 'Antibiotique'),
  ProductCategory('antipyretics', 'Antipyretics (Fever reducers)'),
  ProductCategory('anti_inflammatory', 'Anti-inflammatory drugs'),
  ProductCategory('antiseptics', 'Antiseptics and disinfectants'),
  ProductCategory('antimalarial', 'Antimalarial drugs'),
  ProductCategory('antidiabetics', 'Antidiabetics'),
  ProductCategory('antihypertensives', 'Antihypertensives'),
  ProductCategory('antihistamines', 'Antihistamines'),
  ProductCategory('vitamine', 'Vitamine and supplements'),
  ProductCategory('vaccin', 'Vaccin'),
  ProductCategory('medical_supplies', 'Medical supplies'),
  ProductCategory('dermatological', 'Dermatological products'),
  ProductCategory('gastrointestinal', 'Gastrointestinal medicines'),
  ProductCategory('respiratory', 'Respiratory medicines'),
  ProductCategory('ophthalmic', 'Ophthalmic products (eye medicines)'),
  ProductCategory('injectable', 'Injectable medicines'),
  ProductCategory('pediatric', 'Pediatric medicines'),
  ProductCategory('herbal', 'Herbal medicines'),
];

ProductCategory? getCategoryByValue(String value) {
  try {
    return productCategories.firstWhere((category) => category.value == value);
  } catch (e) {
    return null;
  }
}

String? getCategoryLabel(String value) {
  final category = getCategoryByValue(value);
  return category?.label;
}
