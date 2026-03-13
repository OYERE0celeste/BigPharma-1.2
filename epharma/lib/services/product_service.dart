import '../models/product_model.dart';

class ProductService {
  final List<Product> _products = [];

  Future<List<Product>> getProducts() async {
    // simulate network
    await Future.delayed(const Duration(milliseconds: 120));
    return List<Product>.from(_products);
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> updateProduct(Product product) async {
    final idx = _products.indexWhere((x) => x.id == product.id);
    if (idx >= 0) _products[idx] = product;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((x) => x.id == id);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStock(
    String productId,
    String lotNumber,
    int quantityChange,
  ) async {
    final product = getById(productId);
    if (product != null) {
      final updatedLots = product.lots.map((lot) {
        if (lot.lotNumber == lotNumber) {
          return lot.copyWith(
            quantityAvailable: lot.quantityAvailable + quantityChange,
          );
        }
        return lot;
      }).toList();
      final updatedProduct = product.copyWith(lots: updatedLots);
      await updateProduct(updatedProduct);
    }
  }
}
