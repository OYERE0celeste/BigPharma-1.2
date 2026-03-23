import 'dart:convert';
import 'package:epharma/models/sale_model.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class SalesApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/sales';
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

  static Future<List<Sale>> getSales({int page = 1, int limit = 50}) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = _safeDecode(response.body);
        if (decoded is Map<String, dynamic> &&
            decoded['success'] == true &&
            decoded['data'] is List) {
          final List<dynamic> salesJson = decoded['data'];
          return salesJson.map((json) => Sale.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Sale?> createSale({
    required String invoiceNumber,
    required String clientId,
    required String pharmacistId,
    required List<CartItem> cartItems,
    required double discount,
    required double tax,
    required String paymentMethod,
    required double amountReceived,
    required bool prescriptionVerified,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final subtotal = cartItems.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );
      final total = subtotal - discount + tax;
      final change = amountReceived - total;

      final body = {
        'invoiceNumber': invoiceNumber,
        'client': clientId,
        'pharmacist': pharmacistId,
        'items': cartItems.map((item) => item.toJson()).toList(),
        'discount': discount,
        'tax': tax,
        'paymentMethod': paymentMethod,
        'amountReceived': amountReceived,
        'changeAmount': change,
        'prescriptionVerified': prescriptionVerified,
        'notes': 'Vente en point de vente',
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final decoded = _safeDecode(response.body);
        if (decoded is Map<String, dynamic> &&
            decoded['success'] == true &&
            decoded['data'] is Map<String, dynamic>) {
          return Sale.fromJson(decoded['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
