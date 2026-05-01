import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const _timeoutDuration = Duration(seconds: 15);
  static const _maxRetries = 3;

  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() requestFn, {
    int retries = _maxRetries,
  }) async {
    try {
      return await requestFn().timeout(_timeoutDuration);
    } catch (e) {
      if (retries > 0 && (e is SocketException || e is TimeoutException)) {
        await Future.delayed(Duration(seconds: _maxRetries - retries + 1));
        return _requestWithRetry(requestFn, retries: retries - 1);
      }
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint) async {
    try {
      return await _requestWithRetry(
        () async => await http.get(Uri.parse(endpoint), headers: await _headers),
      );
    } catch (e) {
      return _handleError(e, 'GET', endpoint);
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _requestWithRetry(
        () async => await http.post(
          Uri.parse(endpoint),
          headers: await _headers,
          body: json.encode(body),
        ),
        retries: 0, // No retry for POST to avoid duplicate operations
      );
    } catch (e) {
      return _handleError(e, 'POST', endpoint);
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _requestWithRetry(
        () async => await http.put(
          Uri.parse(endpoint),
          headers: await _headers,
          body: json.encode(body),
        ),
      );
    } catch (e) {
      return _handleError(e, 'PUT', endpoint);
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      return await _requestWithRetry(
        () async => await http.delete(Uri.parse(endpoint), headers: await _headers),
      );
    } catch (e) {
      return _handleError(e, 'DELETE', endpoint);
    }
  }

  http.Response _handleError(dynamic e, String method, String endpoint) {
    String message = 'Une erreur est survenue';
    if (e is SocketException) message = 'Impossible de contacter le serveur. Vérifiez votre connexion.';
    if (e is TimeoutException) message = 'Le serveur met trop de temps à répondre.';
    
    return http.Response(
      json.encode({'success': false, 'message': message, 'error': e.toString()}),
      e is TimeoutException ? 408 : 500,
    );
  }
}
