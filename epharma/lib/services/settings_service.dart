import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_service.dart';

class SettingsService {
  final AuthService _authService = AuthService();

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty response (${response.statusCode})');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final headers = await _authService.getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.settingsProfile),
      headers: headers,
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? 'Erreur chargement paramètres');
  }

  Future<void> updatePermissions(Map<String, bool> permissions) async {
    final headers = await _authService.getHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.settingsPermissions),
      headers: headers,
      body: jsonEncode({'permissions': permissions}),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur mise à jour permissions');
    }
  }

  Future<bool> updateTwoFactor(bool enabled) async {
    final headers = await _authService.getHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.settingsTwoFactor),
      headers: headers,
      body: jsonEncode({'enabled': enabled}),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur mise à jour 2FA');
    }

    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      return payload['enabled'] == true;
    }
    return false;
  }

  Future<void> backupData() async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.settingsBackup),
      headers: headers,
      body: '{}',
    );
    final data = _decode(response);
    if ((response.statusCode != 200 && response.statusCode != 202) ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur sauvegarde');
    }
  }

  Future<void> restoreData(String jsonContent) async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.settingsRestore),
      headers: headers,
      body: jsonEncode({'content': jsonContent}),
    );
    final data = _decode(response);
    if ((response.statusCode != 200 && response.statusCode != 202) ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur restauration');
    }
  }

  Future<void> exportData(String format) async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.settingsExport),
      headers: headers,
      body: jsonEncode({'format': format}),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur export');
    }
  }

  Future<void> importData(String jsonContent) async {
    final headers = await _authService.getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.settingsImport),
      headers: headers,
      body: jsonEncode({'content': jsonContent, 'format': 'json'}),
    );
    final data = _decode(response);
    if ((response.statusCode != 200 && response.statusCode != 202) ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Erreur import');
    }
  }
}
