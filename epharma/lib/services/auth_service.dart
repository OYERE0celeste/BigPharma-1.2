import 'dart:convert';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'api_constants.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([
    this.message = 'Session expirée. Veuillez vous reconnecter.',
  ]);
  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String unauthorizedMsg = 'UNAUTHORIZED';

  String? _token;
  String? _refreshToken;
  Future<String?>? _refreshRequest;
  String? get token => _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConstants.tokenKey);
    return _token;
  }

  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) return _refreshToken;
    final prefs = await SharedPreferences.getInstance();
    _refreshToken = prefs.getString(ApiConstants.refreshTokenKey);
    return _refreshToken;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
  }

  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
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
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
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

    if (response.statusCode == 401) {
      String msg = 'Session expirée';
      String? code;

      if (data is Map<String, dynamic>) {
        msg = data['message']?.toString() ?? msg;
        code = data['code']?.toString();
      }

      // Only logout for token issues, not for wrong password or other 401s
      if (code == 'INVALID_PASSWORD') {
        return msg;
      }

      throw UnauthorizedException(msg);
    }
    if (data is Map<String, dynamic>) {
      final message = _readErrorValue(data['message']);
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
      final error = _readErrorValue(data['error']);
      if (error.isNotEmpty) return error;
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        final nestedMessage = _readErrorValue(
          nested['message'] ?? nested['error'],
        );
        if (nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }
    return '$defaultMessage (${response.statusCode})';
  }

  String _readErrorValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    if (value is Map<String, dynamic>) {
      final message = value['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) {
        return message;
      }
      final error = value['error']?.toString().trim() ?? '';
      if (error.isNotEmpty) {
        return error;
      }
    }
    return value.toString().trim();
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
    final token = await getValidToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> getValidToken() async {
    final token = await getToken();
    if (token == null) return null;

    if (!_isTokenExpired(token)) {
      return token;
    }

    return await refreshAccessToken();
  }

  bool _isTokenExpired(String token, {int leewaySeconds = 30}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = payloadMap['exp'];
      if (exp is! num) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return expiry.isBefore(
        DateTime.now().add(Duration(seconds: leewaySeconds)),
      );
    } catch (_) {
      return true;
    }
  }

  Future<String?> refreshAccessToken() async {
    if (_refreshRequest != null) {
      return _refreshRequest!;
    }

    final completer = Completer<String?>();
    _refreshRequest = completer.future;

    () async {
      try {
        final refreshToken = await getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await clearToken();
          throw UnauthorizedException();
        }

        final response = await _sendRequest(
          () => http.post(
            Uri.parse(ApiConstants.refreshToken),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': refreshToken}),
          ),
        );

        final data = _safeDecode(response);
        if (response.statusCode == 200 && data['success'] == true) {
          final newAccessToken =
              data['data']?['token'] ??
              data['data']?['accessToken'] ??
              data['token'];
          final newRefreshToken = data['data']?['refreshToken'];

          if (newAccessToken is String && newAccessToken.isNotEmpty) {
            await saveAuthTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken is String ? newRefreshToken : null,
            );
            completer.complete(newAccessToken);
            return;
          }
        }

        await clearToken();
        throw UnauthorizedException(
          'Session expiree. Veuillez vous reconnecter.',
        );
      } catch (error) {
        if (error is UnauthorizedException) {
          completer.completeError(error);
        } else {
          completer.completeError(
            UnauthorizedException(
              'Session expiree. Veuillez vous reconnecter.',
            ),
          );
        }
      } finally {
        _refreshRequest = null;
      }
    }();

    return completer.future;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      ),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200 && data['success'] == true) {
      final token =
          data['data']?['token'] ??
          data['data']?['accessToken'] ??
          data['token'];
      final refreshToken = data['data']?['refreshToken'];
      if (token is String && token.isNotEmpty) {
        await saveAuthTokens(
          accessToken: token,
          refreshToken: refreshToken is String ? refreshToken : null,
        );
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
      final token =
          data['data']?['token'] ??
          data['data']?['accessToken'] ??
          data['token'];
      final refreshToken = data['data']?['refreshToken'];
      if (token is String && token.isNotEmpty) {
        await saveAuthTokens(
          accessToken: token,
          refreshToken: refreshToken is String ? refreshToken : null,
        );
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
    required String phone,
    required String address,
    String? username,
  }) async {
    final headers = await getHeaders();
    final body = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'phoneNumber': phone.trim(),
      'address': address.trim(),
    };
    if (username != null && username.trim().isNotEmpty) {
      body['username'] = username.trim().toLowerCase();
    }

    final response = await _sendRequest(
      () => http.put(
        Uri.parse(ApiConstants.me),
        headers: headers,
        body: jsonEncode(body),
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

  Future<void> requestPasswordReset(String identifier) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier}),
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

  Future<void> resetPassword(String otp, String newPassword) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp, 'password': newPassword}),
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
        Uri.parse("${ApiConstants.baseUrl}/users/staff"),
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
        Uri.parse("${ApiConstants.baseUrl}/users/staff"),
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
      () => http.patch(
        Uri.parse("${ApiConstants.baseUrl}/users/staff/$userId"),
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

  Future<void> deleteUser(String userId) async {
    final headers = await getHeaders();
    final response = await _sendRequest(
      () => http.delete(
        Uri.parse("${ApiConstants.baseUrl}/users/staff/$userId"),
        headers: headers,
      ),
    );

    final data = _safeDecode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        _extractErrorMessage(
          response,
          defaultMessage: 'Erreur lors de la suppression',
        ),
      );
    }
  }
}
