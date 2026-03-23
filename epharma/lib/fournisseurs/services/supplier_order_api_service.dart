import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/supplier_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';

class SupplierOrderApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/supplier-orders';
  static final AuthService _authService = AuthService();

  static Future<List<SupplierOrder>> getAllOrders() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? [];
        if (data is List) {
          return data.map((json) => SupplierOrder.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<SupplierOrder?> createOrder(SupplierOrder order) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(order.toJson()),
      );
      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data != null) {
          return SupplierOrder.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<SupplierOrder?> updateOrderStatus(
    String id,
    SupplierOrderStatus status,
  ) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status'),
        headers: headers,
        body: json.encode({'status': status.name}),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data != null) {
          return SupplierOrder.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteOrder(String id) async {
    try {
      final headers = await _authService.getHeaders();
      await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    } catch (_) {}
  }
}
