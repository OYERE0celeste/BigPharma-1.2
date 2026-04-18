import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ClientApiService {
  static String get baseUrl => ApiConstants.clientMe;

  Future<Map<String, dynamic>?> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    if (token == null) return null;
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get the profile of the logged-in client
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final headers = await getHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.clientMe),
        headers: headers as Map<String, String>,
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'data': body['data'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erreur lors de la récupération du profil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  /// Update the client profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.put(
        Uri.parse(ApiConstants.clientMe),
        headers: headers as Map<String, String>,
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'data': body['data'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erreur lors de la mise à jour du profil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }
}
