import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (kIsWeb) {
      if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
        return 'http://127.0.0.1:5000/api';
      }
      return '${Uri.base.origin}/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }

    return 'http://127.0.0.1:5000/api';
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get changePassword => '$baseUrl/auth/change-password';

  static String get settingsProfile => '$baseUrl/settings/profile';
  static String get settingsPermissions => '$baseUrl/settings/permissions';
  static String get settingsTwoFactor => '$baseUrl/settings/2fa';
  static String get settingsBackup => '$baseUrl/settings/backup';
  static String get settingsRestore => '$baseUrl/settings/restore';
  static String get settingsExport => '$baseUrl/settings/export';
  static String get settingsImport => '$baseUrl/settings/import';
  static String get consultations => '$baseUrl/consultations';
  static String get questionsClients => '$baseUrl/QuestionsClients';
  static String get mouvements => '$baseUrl/mouvements';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String companyKey = 'auth_company';
}
