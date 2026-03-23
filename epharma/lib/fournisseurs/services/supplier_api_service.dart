import 'dart:convert';
//import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/supplier_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class SupplierApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/suppliers';
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

  // GET - Récupérer tous les fournisseurs
  static Future<List<Supplier>> getAllSuppliers() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final decoded = _safeDecode(response.body);
        final data = decoded['data'] ?? decoded;

        if (data is List) {
          return data.map((item) {
            try {
              return Supplier.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              // Mapping robuste même en cas d'erreur
              String fallbackId = '';
              if (item.containsKey('_id') && item['_id'] != null) {
                fallbackId = item['_id'].toString();
              } else if (item.containsKey('id') && item['id'] != null) {
                fallbackId = item['id'].toString();
              } else {
                fallbackId = 'error_${DateTime.now().millisecondsSinceEpoch}';
              }

              return Supplier(
                id: fallbackId,
                name: item['name']?.toString() ?? 'Erreur parsing',
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
        }
        throw Exception('Données fournisseurs invalides');
      } else {
        throw Exception(
          _makeErrorMessage(
            response,
            'Erreur lors du chargement des fournisseurs',
          ),
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // GET - Récupérer un fournisseur par ID
  static Future<Supplier> getSupplierById(String id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = _safeDecode(response.body);
        final data = decoded['data'] ?? decoded;
        if (data is Map<String, dynamic>) {
          return Supplier.fromJson(data);
        }
        throw Exception('Réponse serveur invalide');
      }
      throw Exception(_makeErrorMessage(response, 'Fournisseur non trouvé'));
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // POST - Ajouter un nouveau fournisseur
  static Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(supplier.toJson()),
      );

      if (response.statusCode == 201) {
        final decoded = _safeDecode(response.body);
        final data = decoded['data'] ?? decoded;
        if (data is Map<String, dynamic>) {
          return Supplier.fromJson(data);
        }
        throw Exception('Réponse serveur invalide');
      }
      throw Exception(_makeErrorMessage(response, 'Erreur lors de l\'ajout'));
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // PUT - Mettre à jour un fournisseur
  static Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/${supplier.id}'),
        headers: headers,
        body: json.encode(supplier.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = _safeDecode(response.body);
        final data = decoded['data'] ?? decoded;
        if (data is Map<String, dynamic>) {
          return Supplier.fromJson(data);
        }
        throw Exception('Réponse serveur invalide');
      }
      throw Exception(
        _makeErrorMessage(response, 'Erreur lors de la mise à jour'),
      );
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // DELETE - Supprimer un fournisseur
  static Future<void> deleteSupplier(String id) async {
    if (id.isEmpty || id.startsWith('temp_') || id.startsWith('error_')) {
      throw Exception('ID fournisseur invalide - impossible de supprimer');
    }

    try {
      final headers = await _authService.getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) return;

      throw Exception(
        _makeErrorMessage(response, 'Erreur lors de la suppression'),
      );
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
