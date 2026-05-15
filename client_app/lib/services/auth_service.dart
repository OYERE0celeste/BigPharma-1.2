import 'dart:convert';
import '../models/user.dart';
import 'api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  String _readErrorValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    if (value is Map<String, dynamic>) {
      final message = value['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) {
        return message;
      }
      final error = value['error']?.toString().trim() ?? '';
      if (error.isNotEmpty) {
        return error;
      }
    }
    return value.toString().trim();
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _apiService.post(ApiConstants.authLogin, {
        'identifier': identifier,
        'password': password,
      });

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'token': body['data']['token'],
          'user': User.fromJson(body['data']['user']),
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erreur lors de la connexion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
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
    try {
      final response = await _apiService.post(ApiConstants.authRegister, {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'address': address ?? '',
        'companyId': companyId,
      });

      final body = json.decode(response.body);
      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'token': body['data']['token'],
          'user': User.fromJson(body['data']['user']),
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? "Erreur lors de l'inscription",
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    String? username,
  }) async {
    try {
      final body = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
      };
      if (username != null) body['username'] = username;

      final response = await _apiService.put(ApiConstants.authMe, body);

      final respBody = json.decode(response.body);
      if (response.statusCode == 200 && respBody['success'] == true) {
        return {'success': true, 'user': User.fromJson(respBody['data'])};
      } else {
        final message = _readErrorValue(respBody['message']);
        final error = _readErrorValue(respBody['error']);
        return {
          'success': false,
          'message': message.isNotEmpty
              ? message
              : error.isNotEmpty
              ? error
              : 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(ApiConstants.authChangePassword, {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message':
              body['message'] ?? 'Erreur lors du changement de mot de passe',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.authMe);
      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> requestPasswordReset(String identifier) async {
    try {
      final response = await _apiService.post(ApiConstants.authForgotPassword, {
        'identifier': identifier,
      });

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['data']['message']};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erreur lors de la demande',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String otp, String newPassword) async {
    try {
      final response = await _apiService.post(ApiConstants.authResetPassword, {
        'otp': otp,
        'password': newPassword,
      });

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['data']['message']};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erreur lors de la réinitialisation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur $e',
      };
    }
  }
}
