import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/finance_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class FinanceApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/finance';
  static final AuthService _authService = AuthService();

  static dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  static String _makeErrorMessage(
    http.Response response,
    String defaultMessage,
  ) {
    final decoded = _safeDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return '$defaultMessage (${response.statusCode}): ${response.body}';
  }

  static Future<List<FinanceTransactionModel>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (type != null) {
        queryParams['type'] = type;
      }

      final uri = queryParams.isNotEmpty
          ? Uri.parse(baseUrl).replace(queryParameters: queryParams)
          : Uri.parse(baseUrl);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decoded = _safeDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        return data
            .map(
              (item) => FinanceTransactionModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      throw Exception(
        _makeErrorMessage(response, 'Failed to load transactions'),
      );
    } catch (e) {
      debugPrint('Finance API Error: $e');
      rethrow;
    }
  }

  static Future<FinanceTransactionModel> createTransaction(
    FinanceTransactionModel transaction,
  ) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 201) {
        final decoded = _safeDecode(response.body);
        return FinanceTransactionModel.fromJson(decoded['data']);
      }
      throw Exception(
        _makeErrorMessage(response, 'Failed to create transaction'),
      );
    } catch (e) {
      debugPrint('Finance API Error: $e');
      rethrow;
    }
  }
}
