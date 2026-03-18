import 'dart:convert';
import 'package:epharma/models/client_model.dart';
import 'package:http/http.dart' as http;

class ClientApiService {
  static const String baseUrl = 'http://localhost:5000/api/clients';

  static List<Client> _parseClientsList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data
            .map((item) => Client.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    if (body is List) {
      return body
          .map((item) => Client.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  static Client _parseClientObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['data'] is Map<String, dynamic>) {
        return Client.fromJson(body['data'] as Map<String, dynamic>);
      }
      return Client.fromJson(body);
    }
    throw Exception('Réponse serveur invalide');
  }

  static Future<List<Client>> getAllClients({
    String? search,
    String? gender,
    bool? hasMedicalHistory,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (gender != null && gender.trim().isNotEmpty) {
      query['gender'] = gender.trim();
    }
    if (hasMedicalHistory != null) {
      query['hasMedicalHistory'] = hasMedicalHistory.toString();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return _parseClientsList(decoded);
    }
    throw Exception('Erreur chargement clients: ${response.statusCode}');
  }

  static Future<Client> getClientById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return _parseClientObject(decoded);
    }
    throw Exception('Client non trouvé: ${response.statusCode}');
  }

  static Future<Client> createClient(Client client) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(client.toJson()..remove('id')),
    );

    if (response.statusCode == 201) {
      final decoded = json.decode(response.body);
      return _parseClientObject(decoded);
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      throw Exception(decoded['message'].toString());
    }
    throw Exception('Erreur création client: ${response.statusCode}');
  }

  static Future<Client> updateClient(String id, Client client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(client.toJson()..remove('id')),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return _parseClientObject(decoded);
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      throw Exception(decoded['message'].toString());
    }
    throw Exception('Erreur mise à jour client: ${response.statusCode}');
  }

  static Future<void> deleteClient(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) return;

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      throw Exception(decoded['message'].toString());
    }
    throw Exception('Erreur suppression client: ${response.statusCode}');
  }
}
