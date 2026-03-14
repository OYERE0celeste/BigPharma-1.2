import 'dart:convert';
import 'package:epharma/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String baseUrl = 'http://localhost:5000/api/products';

  // GET - Récupérer tous les produits
  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body['data'] ?? body['products'] ?? [];
      final List<dynamic> jsonResponse = data is List ? data : [];
      return jsonResponse
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erreur lors du chargement des produits: ${response.statusCode}',
      );
    }
  }

  // GET - Récupérer un produit par ID
  static Future<Product> getProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? body['product'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Produit non trouvé: ${response.statusCode}');
    }
  }

  // POST - Ajouter un nouveau produit
  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? body['product'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Erreur lors de l\'ajout: ${response.body}');
    }
  }

  // PUT - Mettre à jour un produit
  static Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? body['product'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.body}');
    }
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
      final body = json.decode(response.body);
      final Map<String, dynamic> jsonResponse =
          (body['data'] ?? body['product'] ?? {}) as Map<String, dynamic>;
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Erreur lors de la mise à jour de stock: ${response.body}',
      );
    }
  }

  // DELETE - Supprimer un produit
  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.body}');
    }
  }
}
