import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSession();
    await refreshUser();
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

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String address,
  }) async {
    final result = await _authService.updateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
    );

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<Map<String, dynamic>> requestPasswordReset(String identifier) async {
    return await _authService.requestPasswordReset(identifier);
  }

  Future<Map<String, dynamic>> resetPassword(String otp, String newPassword) async {
    return await _authService.resetPassword(otp, newPassword);
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_token == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.getCurrentUser();
      if (data != null) {
        _user = User.fromJson(data);
        await _saveSession();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('auth_token', _token!);
    if (_user != null) {
      await prefs.setString('auth_user', json.encode(_user!.toJson()));
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userStr = prefs.getString('auth_user');
    if (userStr != null) {
      try {
        _user = User.fromJson(json.decode(userStr));
      } catch (e) {
        debugPrint('Error loading user session: $e');
      }
    }
    notifyListeners();
  }
}
