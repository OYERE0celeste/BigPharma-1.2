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
  bool get isAuthenticated => _user != null;
  String? get token => _authService.token;

  final AuthService _authService = AuthService();

  String _readableError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final local = await _authService.getStoredSession();
      if (local != null) {
        _user = UserModel.fromJson(local['user']);
        _company = CompanyModel.fromJson(local['company']);
      }

      final data = await _authService.getCurrentUser();
      if (data != null) {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _errorMessage = _readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
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

  Future<void> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestPasswordReset(email);
    } catch (e) {
      _errorMessage = _readableError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(token, newPassword);
    } catch (e) {
      _errorMessage = _readableError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    _user = null;
    _company = null;
    notifyListeners();
  }
}
