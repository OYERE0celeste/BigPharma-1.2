import 'dart:convert';
import '../models/user.dart';
import 'api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.authLogin,
        {
          'email': email,
          'password': password,
        },
      );

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
      return {'success': false, 'message': 'Impossible de contacter le serveur $e'};
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
      final response = await _apiService.post(
        ApiConstants.authRegister,
        {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'address': address ?? '',
          'companyId': companyId,
        },
      );

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
      return {'success': false, 'message': 'Impossible de contacter le serveur $e'};
    }
  }
}
