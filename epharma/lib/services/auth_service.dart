import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_constants.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConstants.tokenKey);
    return _token;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
  }

  // Header helpers
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // API Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la connexion');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String companyName,
    required String companyEmail,
    required String companyPhone,
    required String address,
    required String city,
    required String country,
    required String fullName,
    required String adminEmail,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': companyName,
          'email': companyEmail,
          'phone': companyPhone,
          'address': address,
          'city': city,
          'country': country,
          'fullName': fullName,
          'adminEmail': adminEmail,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? "Erreur lors de l'inscription");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final headers = await getHeaders();
      if (!headers.containsKey('Authorization')) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        await clearToken();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // User Management (Admin)
  Future<List<UserModel>> getUsers() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((u) => UserModel.fromJson(u))
              .toList();
        }
      }
      throw Exception('Erreur lors de la récupération des utilisateurs');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: headers,
        body: jsonEncode(userData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return UserModel.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Erreur lors de la création');
    } catch (e) {
      rethrow;
    }
  }
}
