import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/api_constants.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  static const Duration _cacheDuration = Duration(seconds: 45);

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  int _totalOrders = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, int> _stats = {};
  String? _errorMessage;
  String? _lastQueryKey;
  DateTime? _lastLoadedAt;
  Future<void>? _pendingLoad;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  int get totalOrders => _totalOrders;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Map<String, int> get stats => _stats;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders({
    required AuthProvider authProvider,
    int page = 1,
    String? status,
    String? search,
    bool forceRefresh = false,
  }) async {
    final queryKey = '$page|${status ?? ''}|${search ?? ''}';
    final hasFreshData =
        _orders.isNotEmpty &&
        _lastQueryKey == queryKey &&
        _lastLoadedAt != null &&
        DateTime.now().difference(_lastLoadedAt!) < _cacheDuration;

    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (!forceRefresh && hasFreshData) {
      return;
    }

    final shouldShowLoader = _orders.isEmpty;
    _errorMessage = null;
    if (shouldShowLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _pendingLoad = () async {
      final token = authProvider.token;
      var url = '${ApiConstants.baseUrl}/orders?page=$page&limit=10';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode != 200 || jsonData['success'] != true) {
          _errorMessage = (jsonData['error']?['message'] ??
                  jsonData['message'] ??
                  'Erreur lors du chargement des commandes')
              .toString();
          return;
        }

        final ordersData = jsonData['data'] as List<dynamic>? ?? [];
        _orders = ordersData
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final extra = jsonData['extra'] as Map<String, dynamic>? ?? {};
        final pagination = extra['pagination'] as Map<String, dynamic>? ?? {};
        final stats = extra['stats'] as Map<String, dynamic>? ?? {};

        _totalOrders = ((pagination['total'] ?? _orders.length) as num).toInt();
        _currentPage = ((pagination['page'] ?? page) as num).toInt();
        _totalPages = ((pagination['pages'] ?? 1) as num).toInt();
        _stats = stats.map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
        _lastQueryKey = queryKey;
        _lastLoadedAt = DateTime.now();
      } catch (e) {
        _errorMessage = 'Erreur lors du chargement des commandes : $e';
      } finally {
        _pendingLoad = null;
        if (shouldShowLoader) {
          _isLoading = false;
        }
        notifyListeners();
      }
    }();

    return _pendingLoad!;
  }

  Future<Map<String, dynamic>?> fetchOrderDetails(
    String id,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || jsonData['success'] != true) {
        _errorMessage = (jsonData['error']?['message'] ??
                jsonData['message'] ??
                'Erreur lors du chargement du détail')
            .toString();
        notifyListeners();
        return null;
      }

      final data = jsonData['data'] as Map<String, dynamic>;
      final order = OrderModel.fromJson(data['order'] as Map<String, dynamic>);
      final timelineData = data['timeline'] as List<dynamic>? ?? [];
      final timeline = timelineData
          .map(
            (item) => OrderTimelineEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      return {'order': order, 'timeline': timeline};
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du détail : $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrderStatus(
    String id,
    String status,
    String? note,
    String token,
  ) async {
    try {
      _errorMessage = null;
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/orders/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status, 'note': note}),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return true;
      }

      _errorMessage = (jsonData['error']?['message'] ??
              jsonData['message'] ??
              'Impossible de mettre à jour le statut')
          .toString();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Impossible de mettre à jour le statut : $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData, String token) async {
    try {
      _errorMessage = null;
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && jsonData['success'] == true) {
        return true;
      }

      _errorMessage = (jsonData['error']?['message'] ??
              jsonData['message'] ??
              'Impossible de créer la commande')
          .toString();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Impossible de créer la commande : $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductSubstitutes(
    String productId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/products/$productId/substitutes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && jsonData['success'] == true) {
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching product substitutes: $e');
      return [];
    }
  }

  Future<bool> substituteOrderItem({
    required String orderId,
    required int itemIndex,
    required String substituteProductId,
    required String token,
  }) async {
    try {
      _errorMessage = null;
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/substitute'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'itemIndex': itemIndex,
          'substituteProductId': substituteProductId,
        }),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return true;
      }

      _errorMessage = (jsonData['error']?['message'] ??
              jsonData['message'] ??
              'Impossible de substituer l\'article')
          .toString();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Impossible de substituer l\'article : $e';
      notifyListeners();
      return false;
    }
  }
}
