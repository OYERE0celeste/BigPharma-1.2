import 'package:flutter/foundation.dart';

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

  LoginHistory({
    required this.date,
    required this.device,
    required this.success,
  });
}

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings(
    fullName: 'Dr. Jean Dupont',
    email: 'jean.dupont@pharmacie.fr',
    role: 'admin',
    profileImageUrl: '',
    twoFactorEnabled: false,
    permissions: {
      'gérer produits': true,
      'gérer clients': true,
      'gérer ventes': true,
      'gérer fournisseurs': true,
      'accès finances': true,
    },
    loginHistory: [
      LoginHistory(
        date: DateTime.now().subtract(const Duration(hours: 2)),
        device: 'Web - Chrome',
        success: true,
      ),
      LoginHistory(
        date: DateTime.now().subtract(const Duration(days: 1)),
        device: 'Mobile - Android',
        success: true,
      ),
      LoginHistory(
        date: DateTime.now().subtract(const Duration(days: 2)),
        device: 'Web - Firefox',
        success: false,
      ),
    ],
  );

  UserSettings get settings => _settings;

  final List<String> _availableRoles = ['admin', 'pharmacien', 'assistant'];
  List<String> get availableRoles => _availableRoles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      // Dans une version future, ceci appellera api/users/profile
      // Pour l'instant on garde les données par défaut mais via une structure prête
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
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
      // Simuler appel API vers api/users/profile
      await Future.delayed(const Duration(seconds: 1));

      if (!_isValidEmail(email)) {
        setError('Email invalide');
        setLoading(false);
        return false;
      }

      _settings = _settings.copyWith(
        fullName: fullName,
        email: email,
        role: role,
      );

      notifyListeners();
      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour du profil');
      setLoading(false);
      return false;
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
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Validation
      if (currentPassword.length < 6) {
        setError('Le mot de passe actuel est incorrect');
        setLoading(false);
        return false;
      }

      if (newPassword.length < 8) {
        setError('Le nouveau mot de passe doit contenir au moins 8 caractères');
        setLoading(false);
        return false;
      }

      if (newPassword != confirmPassword) {
        setError('Les mots de passe ne correspondent pas');
        setLoading(false);
        return false;
      }

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors du changement de mot de passe');
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfileImage(String imageUrl) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      _settings = _settings.copyWith(profileImageUrl: imageUrl);

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour de la photo de profil');
      setLoading(false);
      return false;
    }
  }

  Future<bool> toggleTwoFactor(bool enabled) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      _settings = _settings.copyWith(twoFactorEnabled: enabled);

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour de l\'authentification à deux facteurs');
      setLoading(false);
      return false;
    }
  }

  Future<bool> updatePermission(String key, bool value) async {
    final Map<String, bool> newPermissions = Map.from(_settings.permissions);
    newPermissions[key] = value;
    return await updatePermissions(newPermissions);
  }

  Future<bool> updatePermissions(Map<String, bool> permissions) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      _settings = _settings.copyWith(permissions: permissions);

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour des permissions');
      setLoading(false);
      return false;
    }
  }

  Future<bool> backupData() async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la sauvegarde des données');
      setLoading(false);
      return false;
    }
  }

  Future<bool> restoreData(String filePath) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de la restauration des données');
      setLoading(false);
      return false;
    }
  }

  Future<bool> exportData(String format) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de l\'exportation des données');
      setLoading(false);
      return false;
    }
  }

  Future<bool> importData(String filePath) async {
    setLoading(true);
    clearError();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erreur lors de l\'importation des données');
      setLoading(false);
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
