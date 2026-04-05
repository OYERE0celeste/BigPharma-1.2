import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/api_constants.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  int _totalOrders = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  int get totalOrders => _totalOrders;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchOrders({
    required AuthProvider authProvider,
    int page = 1,
    String? status,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = authProvider.token;
      String url = '${ApiConstants.baseUrl}/orders?page=$page&limit=10';
      if (status != null && status.isNotEmpty) url += '&status=$status';
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> ordersData = jsonData['data'];
        _orders = ordersData.map((item) => OrderModel.fromJson(item)).toList();
        _totalOrders = jsonData['pagination']['total'];
        _currentPage = jsonData['pagination']['page'];
        _totalPages = jsonData['pagination']['pages'];
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchOrderDetails(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final order = OrderModel.fromJson(jsonData['data']['order']);
        final List<dynamic> timelineData = jsonData['data']['timeline'];
        final timeline = timelineData.map((t) => OrderTimelineEntry.fromJson(t)).toList();
        return {'order': order, 'timeline': timeline};
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
    }
    return null;
  }

  Future<bool> createOrder(Map<String, dynamic> orderData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String id, String status, String? note, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/orders/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status, 'note': note}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/orders/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }
}
