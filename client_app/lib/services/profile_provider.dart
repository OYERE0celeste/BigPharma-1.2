import 'package:flutter/material.dart';
import '../services/client_api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ClientApiService _apiService = ClientApiService();
  
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getMyProfile();
    
    _isLoading = false;
    if (result['success']) {
      _profile = result['data'];
    } else {
      _error = result['message'];
    }
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.updateProfile(data);
    
    _isLoading = false;
    if (result['success']) {
      _profile = result['data'];
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }
}
