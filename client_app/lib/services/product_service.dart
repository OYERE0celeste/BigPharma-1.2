import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  static const String _cacheKeyPopular = 'cache_popular_products';

  Future<void> _cacheProducts(String key, List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(products.map((p) => p.toJson()).toList());
    await prefs.setString(key, encodedData);
  }

  Future<List<Product>> _getCachedProducts(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(key);
    if (cachedData != null) {
      final List<dynamic> decodedData = json.decode(cachedData);
      return decodedData.map((j) => Product.fromJson(j)).toList();
    }
    return [];
  }

  Future<List<Product>> getPopularProducts() async {
    try {
      final url = '${ApiConstants.products}?limit=4';
      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final products = data.map((json) => Product.fromJson(json)).toList();
          await _cacheProducts(_cacheKeyPopular, products);
          return products;
        }
      }
      return await _getCachedProducts(_cacheKeyPopular);
    } catch (e) {
      return await _getCachedProducts(_cacheKeyPopular);
    }
  }

  Future<List<Product>> getNewProducts() async {
    try {
      final url = '${ApiConstants.products}?limit=10&page=1';
      print('Fetching new products from: $url');
      final response = await _apiService.get(url);

      print('New products response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          print('Fetched ${data.length} new products');
          return data.map((json) => Product.fromJson(json)).toList();
        }
      }
      print('Failed to fetch new products: ${response.body}');
      return [];
    } catch (e) {
      print('Error in getNewProducts: $e');
      return [];
    }
  }

  Future<Product?> getProductDetails(String productId) async {
    try {
      final response = await _apiService.get('${ApiConstants.products}/$productId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          return Product.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
