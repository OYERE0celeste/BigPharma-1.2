import 'package:flutter/material.dart';

import '../models/company_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  CompanyModel? _company;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  CompanyModel? get company => _company;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _authService.token != null;
  String? get token => _authService.token;

  final AuthService _authService = AuthService();

  String _readableError(Object error) {
    if (error is UnauthorizedException) {
      logout();
      return error.message;
    }
    var message = error.toString().trim();
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length).trim();
    }

    final structuredMessage = RegExp(
      r'message:\s*([^,}]+)',
      caseSensitive: false,
    ).firstMatch(message);

    if (message.startsWith('{') &&
        message.endsWith('}') &&
        structuredMessage != null) {
      return structuredMessage.group(1)?.trim() ?? message;
    }

    return message;
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final local = await _authService.getStoredSession();
      final token = await _authService.getToken();

      if (local != null && token != null) {
        _user = UserModel.fromJson(local['user']);
        _company = CompanyModel.fromJson(local['company']);
      } else {
        _user = null;
        _company = null;
      }

      final data = await _authService.getCurrentUser();
      if (data != null) {
        _user = UserModel.fromJson(data);
      } else {
        _user = null;
        _company = null;
      }
    } catch (e) {
      _errorMessage = _readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      final data = await _authService.getCurrentUser();
      if (data != null) {
        _user = UserModel.fromJson(data);
        if (_company != null) {
          await _authService.saveSessionData(
            user: data,
            company: _company!.toJson(),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = _readableError(e);
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.login(email, password);
      if (responseData['success'] == true) {
        _user = UserModel.fromJson(responseData['data']['user']);
        _company = CompanyModel.fromJson(responseData['data']['company']);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _readableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String companyName,
    required String companyEmail,
    required String companyPhone,
    required String address,
    required String fullName,
    required String adminEmail,
    required String password,
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.register(
        companyName: companyName,
        companyEmail: companyEmail,
        companyPhone: companyPhone,
        address: address,
        city: city,
        country: country.toString(),
        fullName: fullName,
        adminEmail: adminEmail,
        password: password,
      );

      if (responseData['success'] == true) {
        _user = UserModel.fromJson(responseData['data']['user']);
        _company = CompanyModel.fromJson(responseData['data']['company']);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _readableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.updateProfile(
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        phone: phoneNumber.trim(),
        address: address.trim(),
      );

      _user = UserModel.fromJson(responseData);
      return true;
    } catch (e) {
      _errorMessage = _readableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordReset(String identifier) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestPasswordReset(identifier);
    } catch (e) {
      _errorMessage = _readableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword(String otp, String newPassword) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(otp, newPassword);
    } catch (e) {
      _errorMessage = _readableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    _user = null;
    _company = null;
    notifyListeners();
  }
}
