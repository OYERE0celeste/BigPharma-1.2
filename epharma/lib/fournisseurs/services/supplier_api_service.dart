import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/supplier_model.dart';

class SupplierApiService {
  static const String baseUrl = 'http://localhost:5000/api/suppliers';

  // GET - Récupérer tous les fournisseurs
  static Future<List<Supplier>> getAllSuppliers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body) ?? [];
        return jsonResponse.map((item) {
          try {
            return Supplier.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            // Retourner un fournisseur par défaut si la désérialisation échoue
            return Supplier(
              id:
                  item['_id']?.toString() ??
                  item['id']?.toString() ??
                  'unknown',
              name: item['name']?.toString() ?? 'Erreur',
              contactName: item['contactName']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              address: item['address']?.toString() ?? '',
              city: item['city']?.toString() ?? '',
              country: item['country']?.toString() ?? '',
              notes: item['notes']?.toString() ?? '',
              createdAt: DateTime.now(),
            );
          }
        }).toList();
      } else {
        throw Exception(
          'Erreur lors du chargement des fournisseurs: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // GET - Récupérer un fournisseur par ID
  static Future<Supplier> getSupplierById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) ?? {};
        return Supplier.fromJson(jsonResponse);
      } else {
        throw Exception('Fournisseur non trouvé: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // POST - Ajouter un nouveau fournisseur
  static Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(supplier.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) ?? {};
        return Supplier.fromJson(jsonResponse);
      } else {
        final errorResponse =
            json.decode(response.body) as Map<String, dynamic>? ?? {};
        throw Exception(
          'Erreur lors de l\'ajout: ${errorResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // PUT - Mettre à jour un fournisseur
  static Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${supplier.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(supplier.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) ?? {};
        return Supplier.fromJson(jsonResponse);
      } else {
        final errorResponse =
            json.decode(response.body) as Map<String, dynamic>? ?? {};
        throw Exception(
          'Erreur lors de la mise à jour: ${errorResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // DELETE - Supprimer un fournisseur
  static Future<void> deleteSupplier(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        // Succès
        return;
      } else {
        final errorResponse =
            json.decode(response.body) as Map<String, dynamic>? ?? {};
        throw Exception(
          'Erreur lors de la suppression: ${errorResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // Validation des données avant envoi
  static bool validateSupplierData(Supplier supplier) {
    if (supplier.name.isEmpty || supplier.contactName.isEmpty) {
      return false;
    }

    if (!supplier.isValidEmail) {
      return false;
    }

    if (!supplier.isValidPhone) {
      return false;
    }

    return true;
  }

  // Créer un fournisseur depuis les données du formulaire
  static Supplier createSupplierFromForm({
    required String name,
    required String contactName,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String country,
    String notes = '',
  }) {
    return Supplier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
      city: city,
      country: country,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }
}
