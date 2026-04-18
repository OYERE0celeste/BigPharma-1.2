import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    try {
      return await http.get(Uri.parse(endpoint), headers: await _headers);
    } catch (e) {
      print('ApiService GET error: $e');
      return http.Response(json.encode({'success': false, 'message': 'Erreur de connexion'}), 500);
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await http.post(
        Uri.parse(endpoint),
        headers: await _headers,
        body: json.encode(body),
      );
    } catch (e) {
      print('ApiService POST error: $e');
      return http.Response(json.encode({'success': false, 'message': 'Erreur de connexion'}), 500);
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await http.put(
        Uri.parse(endpoint),
        headers: await _headers,
        body: json.encode(body),
      );
    } catch (e) {
      print('ApiService PUT error: $e');
      return http.Response(json.encode({'success': false, 'message': 'Erreur de connexion'}), 500);
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      return await http.delete(Uri.parse(endpoint), headers: await _headers);
    } catch (e) {
      print('ApiService DELETE error: $e');
      return http.Response(json.encode({'success': false, 'message': 'Erreur de connexion'}), 500);
    }
  }
}
