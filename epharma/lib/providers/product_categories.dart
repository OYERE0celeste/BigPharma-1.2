class ProductCategory {
  final String value;
  final String label;

  const ProductCategory(this.value, this.label);

  @override
  String toString() => label;
}

const List<ProductCategory> productCategories = [
  ProductCategory('Dermo-cosmétique', 'Dermo-cosmétique (Soins du visage)'),
  ProductCategory('Hygiène Corporelle', 'Hygiène Corporelle'),
  ProductCategory('Soins Capillaires', 'Soins Capillaires'),
  ProductCategory('Santé Bucco-dentaire', 'Santé Bucco-dentaire'),
  ProductCategory('Maternité et Bébé', 'Maternité et Bébé'),
  ProductCategory('Compléments Alimentaires et Vitamines', 'Compléments Alimentaires et Vitamines'),
  ProductCategory('Premiers Secours et Bobologie', 'Premiers Secours et Bobologie'),
  ProductCategory('Protection Solaire', 'Protection Solaire'),
  ProductCategory('Diététique et Phytothérapie', 'Diététique et Phytothérapie'),
  ProductCategory('vitamine', 'Vitamine and supplements'),
  ProductCategory('Orthopédie et Contention Légère', 'Orthopédie et Contention Légère'),
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
