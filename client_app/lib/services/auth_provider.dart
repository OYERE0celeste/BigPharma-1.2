import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_constants.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService();

  AuthProvider() {
    _loadSession();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    final result = await _authService.login(email, password);
    _setLoading(false);

    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      await _saveSession();
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> registerClient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String gender,
    String? address,
    required String companyId,
  }) async {
    _setLoading(true);
    final result = await _authService.registerClient(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
      companyId: companyId,
    );
    _setLoading(false);

    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      await _saveSession();
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(ApiConstants.tokenKey, _token!);
    if (_user != null) {
      // Logic to save user info if needed, or just re-fetch on start
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConstants.tokenKey);
    // For a real app, we should verify the token here
    notifyListeners();
  }
}
