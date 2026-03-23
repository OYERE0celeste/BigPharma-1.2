import 'dart:convert';
import 'package:epharma/models/product_model.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class ProductApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/products';
  static final AuthService _authService = AuthService();

  static dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  static String _makeErrorMessage(
    http.Response response,
    String defaultMessage,
  ) {
    final decoded = _safeDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return '$defaultMessage (${response.statusCode}): ${response.body}';
  }

  // GET - Récupérer tous les produits
  static Future<List<Product>> getAllProducts() async {
    final headers = await _authService.getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      final data = body['data'] ?? [];
      final List<dynamic> jsonResponse = data is List ? data : [];
      return jsonResponse
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        _makeErrorMessage(response, 'Erreur lors du chargement des produits'),
      );
    }
  }

  // GET - Récupérer un produit par ID
  static Future<Product> getProductById(String id) async {
    final headers = await _authService.getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception(_makeErrorMessage(response, 'Produit non trouvé'));
    }
  }

  // POST - Ajouter un nouveau produit
  static Future<Product> createProduct(Product product) async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      final body = _safeDecode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    }
    throw Exception(_makeErrorMessage(response, 'Erreur lors de l\'ajout'));
  }

  // PUT - Mettre à jour un produit
  static Future<Product> updateProduct(Product product) async {
    final headers = await _authService.getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: headers,
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    }
    throw Exception(
      _makeErrorMessage(response, 'Erreur lors de la mise à jour'),
    );
  }

  // PATCH - Mettre à jour le stock d'un produit
  static Future<Product> updateStock(
    String id,
    int quantity,
    String operation,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/stock'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'quantity': quantity, 'operation': operation}),
    );

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? body['product'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    }
    throw Exception(
      _makeErrorMessage(response, 'Erreur lors de la mise à jour de stock'),
    );
  }

  // DELETE - Supprimer un produit
  static Future<void> deleteProduct(String id) async {
    final headers = await _authService.getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.body}');
    }
  }
}
