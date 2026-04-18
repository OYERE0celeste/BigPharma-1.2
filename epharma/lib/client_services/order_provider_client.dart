import 'package:flutter/material.dart';
import '../client_models/order.dart';
import 'order_service.dart';

class OrderProviderClient with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getMyOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createOrder(
    List<OrderItem> items, {
    String? prescriptionId,
  }) async {
    final result = await _orderService.createOrder(
      items,
      prescriptionId: prescriptionId,
    );

    if (result['success'] == true) {
      await loadMyOrders();
      return result;
    }

    _errorMessage = result['message']?.toString();
    notifyListeners();
    return result;
  }

  Future<Order?> getOrderById(String id) async {
    return _orderService.getOrderById(id);
  }
}
