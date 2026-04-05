import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
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

  // Initialize: check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.getCurrentUser();
      debugPrint('[Auth] checkAuthStatus data: $data');
      if (data != null) {
        _user = UserModel.fromJson(data);
        if (data['companyId'] is Map) {
          _company = CompanyModel.fromJson(data['companyId']);
        }
        debugPrint('[Auth] User authenticated: ${_user?.fullName}');
      }
    } catch (e) {
      _errorMessage = e.toString();
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
      debugPrint('[Auth] Login response: ${responseData['success']}');
      if (responseData['success'] == true) {
        _user = UserModel.fromJson(responseData['data']['user']);
        _company = CompanyModel.fromJson(responseData['data']['company']);
        _isLoading = false;
        debugPrint('[Auth] Login state set. User: ${_user?.fullName}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String companyName,
    required String companyEmail,
    required String companyPhone,
    required String address,
    required String fullName,
    required String adminEmail,
    required String password, required String city, required country,
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
        country: country,
        fullName: fullName,
        adminEmail: adminEmail,
        password: password,
      );

      if (responseData['success'] == true) {
        _user = UserModel.fromJson(responseData['data']['user']);
        _company = CompanyModel.fromJson(responseData['data']['company']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    _user = null;
    _company = null;
    notifyListeners();
  }
}
