import 'dart:convert';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  String? get token => _token;

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

  Future<void> saveSessionData({
    required Map<String, dynamic> user,
    required Map<String, dynamic> company,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.userKey, jsonEncode(user));
    await prefs.setString(ApiConstants.companyKey, jsonEncode(company));
  }

  Future<Map<String, dynamic>?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(ApiConstants.userKey);
    final companyStr = prefs.getString(ApiConstants.companyKey);
    if (userStr == null || companyStr == null) return null;

    try {
      return {'user': jsonDecode(userStr), 'company': jsonDecode(companyStr)};
    } catch (_) {
      return null;
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
    await prefs.remove(ApiConstants.companyKey);
  }

  dynamic _safeDecode(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty server response (${response.statusCode})');
    }
    return jsonDecode(response.body);
  }

  String _extractErrorMessage(
    http.Response response, {
    String defaultMessage = 'Erreur serveur inattendue',
  }) {
    final data = _safeDecode(response);
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? '';
      final details = data['data']?['details'];
      if (details is List) {
        final detailMessages = details
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (detailMessages.isNotEmpty) {
          return [
            message,
            detailMessages.join(' / '),
          ].where((s) => s.isNotEmpty).join(' - ');
        }
      }
      if (message.isNotEmpty) return message;
      if (data['error'] != null) return data['error'].toString();
    }
    return '$defaultMessage (${response.statusCode})';
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception(
        'Le serveur met trop de temps a repondre. Verifiez que l API tourne sur http://localhost:5000.',
      );
    } on http.ClientException {
      throw Exception(
        'Impossible de joindre l API. Verifiez que le backend est demarre sur http://localhost:5000 et que le CORS local est autorise.',
      );
    }
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']?['token'] ?? data['token'];
      if (token is String && token.isNotEmpty) {
        await saveToken(token);
      }
      if (data['data']?['user'] != null && data['data']?['company'] != null) {
        await saveSessionData(
          user: data['data']['user'],
          company: data['data']['company'],
        );
      }
      return data;
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de la connexion',
      ),
    );
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
    final response = await _sendRequest(
      () => http.post(
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
      ),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 201 && data['success'] == true) {
      final token = data['data']?['token'] ?? data['token'];
      if (token is String && token.isNotEmpty) {
        await saveToken(token);
      }
      if (data['data']?['user'] != null && data['data']?['company'] != null) {
        await saveSessionData(
          user: data['data']['user'],
          company: data['data']['company'],
        );
      }
      return data;
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de l\'inscription',
      ),
    );
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final headers = await getHeaders();
    if (!headers.containsKey('Authorization')) return null;

    final response = await _sendRequest(
      () => http.get(Uri.parse(ApiConstants.me), headers: headers),
    );

    if (response.statusCode == 200) {
      final data = _safeDecode(response);
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }
    }

    if (response.statusCode == 401) {
      await clearToken();
    }

    return null;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.put(
        Uri.parse(ApiConstants.me),
        headers: headers,
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
        }),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de la mise à jour du profil',
      ),
    );
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        _extractErrorMessage(
          response,
          defaultMessage: 'Erreur lors de la demande de réinitialisation',
        ),
      );
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': newPassword}),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        _extractErrorMessage(
          response,
          defaultMessage: 'Erreur lors de la réinitialisation',
        ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.changePassword),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        _extractErrorMessage(
          response,
          defaultMessage: 'Erreur lors du changement de mot de passe',
        ),
      );
    }
  }

  Future<List<UserModel>> getUsers() async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.get(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: headers,
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode == 200 &&
        data['success'] == true &&
        data['data'] != null) {
      return (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de la récupération des utilisateurs',
      ),
    );
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.post(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: headers,
        body: jsonEncode(userData),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode == 201 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de la création',
      ),
    );
  }

  Future<UserModel> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.put(
        Uri.parse("${ApiConstants.baseUrl}/users/$userId"),
        headers: headers,
        body: jsonEncode(userData),
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(
      _extractErrorMessage(
        response,
        defaultMessage: 'Erreur lors de la mise à jour de l\'utilisateur',
      ),
    );
  }
}
