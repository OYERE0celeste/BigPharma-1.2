import 'dart:convert';
import 'package:epharma/models/client_model.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class ClientApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/clients';
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
    final headers = await _authService.getHeaders();
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
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = _safeDecode(response.body);
      return _parseClientsList(decoded);
    }
    throw Exception(_makeErrorMessage(response, 'Erreur chargement clients'));
  }

  static Future<Client> getClientById(String id) async {
    final headers = await _authService.getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      final decoded = _safeDecode(response.body);
      return _parseClientObject(decoded);
    }
    throw Exception(_makeErrorMessage(response, 'Client non trouvé'));
  }

  static Future<Client> createClient(Client client) async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(client.toJson()..remove('id')),
    );

    if (response.statusCode == 201) {
      final decoded = _safeDecode(response.body);
      return _parseClientObject(decoded);
    }
    throw Exception(_makeErrorMessage(response, 'Erreur création client'));
  }

  static Future<Client> updateClient(String id, Client client) async {
    final headers = await _authService.getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: json.encode(client.toJson()..remove('id')),
    );

    if (response.statusCode == 200) {
      final decoded = _safeDecode(response.body);
      return _parseClientObject(decoded);
    }
    throw Exception(_makeErrorMessage(response, 'Erreur mise à jour client'));
  }

  static Future<void> deleteClient(String id) async {
    final headers = await _authService.getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) return;
    throw Exception(_makeErrorMessage(response, 'Erreur suppression client'));
  }
}
