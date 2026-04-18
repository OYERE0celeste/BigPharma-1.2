import 'dart:convert';
import '../models/order.dart';
import 'api_constants.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _apiService.get(ApiConstants.myOrders);
      if (response.statusCode != 200) {
        return [];
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return [];
      }

      final data = (body['data'] as List<dynamic>? ?? []);
      return data
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(
    List<OrderItem> items, {
    String? prescriptionId,
  }) async {
    try {
      final orderData = {
        'products': items.map((item) => item.toRequestJson()).toList(),
        if (prescriptionId != null && prescriptionId.isNotEmpty)
          'prescriptionId': prescriptionId,
      };

      final response = await _apiService.post(ApiConstants.orders, orderData);
      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'data': Order.fromJson(body['data'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message':
            (body['message'] ?? 'Erreur lors de la création de la commande')
                .toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de créer la commande : $e',
      };
    }
  }

  Future<Order?> getOrderById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.orders}/$id');
      if (response.statusCode != 200) {
        return null;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return null;
      }

      final data = body['data'];
      if (data is Map<String, dynamic> &&
          data['order'] is Map<String, dynamic>) {
        return Order.fromJson(data['order'] as Map<String, dynamic>);
      }
      if (data is Map<String, dynamic>) {
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
