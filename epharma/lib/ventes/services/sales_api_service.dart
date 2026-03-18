import 'dart:convert';
import 'package:epharma/models/sale_model.dart';
import 'package:http/http.dart' as http;

class SalesApiService {
  static const String baseUrl = 'http://localhost:5000/api/sales';

  static Future<List<Sale>> getSales({int page = 1, int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> salesJson = data['data'];
          return salesJson.map((json) => Sale.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching sales: $e');
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return Sale.fromJson(data['data']);
        }
      }

      print('Create sale failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error creating sale: $e');
      return null;
    }
  }
}
