import 'dart:convert';
import '../models/product.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<List<Product>> getPopularProducts() async {
    try {
      final url = '${ApiConstants.products}?limit=4';
      print('Fetching popular products from: $url');
      final response = await _apiService.get(url);

      print('Popular products response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          print('Fetched ${data.length} popular products');
          return data.map((json) => Product.fromJson(json)).toList();
        }
      }
      print('Failed to fetch popular products: ${response.body}');
      return [];
    } catch (e) {
      print('Error in getPopularProducts: $e');
      return [];
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
