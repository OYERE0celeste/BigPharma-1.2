import '../models/product_model.dart';
import '../products/services/product_api_service.dart';

class ProductService {
  Future<List<Product>> getProducts() async {
    return await ProductApiService.getAllProducts();
  }

  Future<Product> addProduct(Product product) async {
    return await ProductApiService.createProduct(product);
  }

  Future<Product> updateProduct(Product product) async {
    return await ProductApiService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await ProductApiService.deleteProduct(id);
  }

  Future<Product?> getById(String id) async {
    try {
      return await ProductApiService.getProductById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStock(
    String productId,
    String lotNumber,
    int quantityChange,
  ) async {
    final product = await getById(productId);
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

  Future<Product> updateStockQuantity(
    String productId,
    int quantity,
    String operation,
  ) async {
    return await ProductApiService.updateStock(productId, quantity, operation);
  }
}
