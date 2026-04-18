import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/settings_service.dart';

class UserSettings {
  final String fullName;
  final String email;
  final String role;
  final String profileImageUrl;
  final bool twoFactorEnabled;
  final Map<String, bool> permissions;
  final List<LoginHistory> loginHistory;

  UserSettings({
    required this.fullName,
    required this.email,
    required this.role,
    required this.profileImageUrl,
    required this.twoFactorEnabled,
    required this.permissions,
    required this.loginHistory,
  });

  factory UserSettings.empty() {
    return UserSettings(
      fullName: '',
      email: '',
      role: 'assistant',
      profileImageUrl: '',
      twoFactorEnabled: false,
      permissions: {
        'gerer produits': false,
        'gerer clients': false,
        'gerer ventes': false,
        'acces finances': false,
      },
      loginHistory: const [],
    );
  }

  UserSettings copyWith({
    String? fullName,
    String? email,
    String? role,
    String? profileImageUrl,
    bool? twoFactorEnabled,
    Map<String, bool>? permissions,
    List<LoginHistory>? loginHistory,
  }) {
    return UserSettings(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      permissions: permissions ?? this.permissions,
      loginHistory: loginHistory ?? this.loginHistory,
    );
  }
}

class LoginHistory {
  final DateTime date;
  final String device;
  final bool success;

  const LoginHistory({
    required this.date,
    required this.device,
    required this.success,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      device: json['device']?.toString() ?? 'Unknown',
      success: json['success'] == true,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final AuthService _authService = AuthService();

  UserSettings _settings = UserSettings.empty();
  UserSettings get settings => _settings;

  final List<String> _availableRoles = [
    'admin',
    'pharmacien',
    'assistant',
    'caissier',
  ];
  List<String> get availableRoles => _availableRoles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isMockData = false;
  bool get isMockData => _isMockData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    setLoading(true);
    clearError();

    try {
      final payload = await _settingsService.loadSettings();

      final permissions = <String, bool>{};
      final rawPermissions = payload['permissions'];
      if (rawPermissions is Map) {
        for (final entry in rawPermissions.entries) {
          permissions[entry.key.toString()] = entry.value == true;
        }
      }

      final history = <LoginHistory>[];
      final rawHistory = payload['loginHistory'];
      if (rawHistory is List) {
        history.addAll(
          rawHistory.whereType<Map>().map(
            (e) => LoginHistory.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      }

      _settings = _settings.copyWith(
        fullName: payload['fullName']?.toString() ?? '',
        email: payload['email']?.toString() ?? '',
        role: payload['role']?.toString() ?? 'assistant',
        profileImageUrl: payload['profileImageUrl']?.toString() ?? '',
        twoFactorEnabled: payload['twoFactorEnabled'] == true,
        permissions: permissions.isEmpty ? _settings.permissions : permissions,
        loginHistory: history,
      );

      _isMockData = false;
      notifyListeners();
    } catch (e) {
      _isMockData = true;
      setError('Erreur lors du chargement des paramètres');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String role,
  }) async {
    setLoading(true);
    clearError();

    try {
      final updated = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: '',
      );

      _settings = _settings.copyWith(
        fullName: updated['fullName']?.toString() ?? fullName,
        email: updated['email']?.toString() ?? email,
        role: role,
      );
      notifyListeners();
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour du profil');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    setLoading(true);
    clearError();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      setError('Erreur lors du changement de mot de passe');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProfileImage(String imageUrl) async {
    _settings = _settings.copyWith(profileImageUrl: imageUrl);
    notifyListeners();
    return true;
  }

  Future<bool> toggleTwoFactor(bool enabled) async {
    setLoading(true);
    clearError();

    try {
      final actualEnabled = await _settingsService.updateTwoFactor(enabled);
      _settings = _settings.copyWith(twoFactorEnabled: actualEnabled);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour de la 2FA');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updatePermission(String key, bool value) async {
    final newPermissions = Map<String, bool>.from(_settings.permissions);
    newPermissions[key] = value;
    return updatePermissions(newPermissions);
  }

  Future<bool> updatePermissions(Map<String, bool> permissions) async {
    setLoading(true);
    clearError();

    try {
      await _settingsService.updatePermissions(permissions);
      _settings = _settings.copyWith(permissions: permissions);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour des permissions');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> backupData() async {
    setLoading(true);
    clearError();
    try {
      await _settingsService.backupData();
      return true;
    } catch (e) {
      setError('Erreur lors de la sauvegarde des données');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> restoreData(String jsonContent) async {
    setLoading(true);
    clearError();
    try {
      await _settingsService.restoreData(jsonContent);
      return true;
    } catch (e) {
      setError('Erreur lors de la restauration des données');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> exportData(String format) async {
    setLoading(true);
    clearError();
    try {
      await _settingsService.exportData(format);
      return true;
    } catch (e) {
      setError('Erreur lors de l\'exportation des données');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> importData(String jsonContent) async {
    setLoading(true);
    clearError();
    try {
      await _settingsService.importData(jsonContent);
      return true;
    } catch (e) {
      setError('Erreur lors de l\'importation des données');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
