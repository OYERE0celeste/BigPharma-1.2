import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order_invoice_model.dart';
import 'api_constants.dart';
import 'auth_service.dart';

class OrderInvoiceService {
  OrderInvoiceService._();

  static final AuthService _authService = AuthService();

  static dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  static Future<OrderInvoiceModel?> fetchOrderInvoice(String orderId) async {
    final headers = await _authService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/invoice'),
      headers: headers,
    );

    final decoded = _safeDecode(response.body);

    if (response.statusCode == 200 &&
        decoded is Map<String, dynamic> &&
        decoded['success'] == true &&
        decoded['data'] is Map<String, dynamic>) {
      return OrderInvoiceModel.fromJson(decoded['data'] as Map<String, dynamic>);
    }

    if (response.statusCode == 404) {
      return null;
    }

    if (decoded is Map<String, dynamic>) {
      final message =
          decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          'Impossible de charger la facture commande.';
      throw Exception(message);
    }

    throw Exception('Impossible de charger la facture commande.');
  }
}
