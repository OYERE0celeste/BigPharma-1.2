import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  SharedPreferences? _prefs;
  String? _cachedToken;

  Future<SharedPreferences> get _sharedPreferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<String?> _loadToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await _sharedPreferences;
    _cachedToken = prefs.getString(ApiConstants.tokenKey);
    return _cachedToken;
  }

  Future<void> setToken(String? token) async {
    _cachedToken = token;
    final prefs = await _sharedPreferences;
    if (token == null) {
      await prefs.remove(ApiConstants.tokenKey);
    } else {
      await prefs.setString(ApiConstants.tokenKey, token);
    }
  }

  Future<Map<String, String>> get _headers async {
    final token = await _loadToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _loadToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<http.Response> get(String endpoint) async {
    try {
      return await http.get(Uri.parse(endpoint), headers: await _headers);
    } catch (e) {
      print('ApiService GET error: $e');
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
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
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
    }
  }

  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _authHeaders);
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      return http.Response(
        responseBody,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
      );
    } catch (e) {
      print('ApiService multipart POST error: $e');
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
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
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
    }
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      return await http.patch(
        Uri.parse(endpoint),
        headers: await _headers,
        body: json.encode(body),
      );
    } catch (e) {
      print('ApiService PATCH error: $e');
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      return await http.delete(Uri.parse(endpoint), headers: await _headers);
    } catch (e) {
      print('ApiService DELETE error: $e');
      return http.Response(
        json.encode({'success': false, 'message': 'Erreur de connexion'}),
        500,
      );
    }
  }
}
