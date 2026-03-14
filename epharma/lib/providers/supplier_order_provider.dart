import 'package:flutter/foundation.dart';
import '../models/supplier_model.dart';

class SupplierOrderProvider extends ChangeNotifier {
  List<SupplierOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<SupplierOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOrders => _orders.length;
  int get pendingOrders =>
      _orders.where((o) => o.status == SupplierOrderStatus.pending).length;
  int get confirmedOrders =>
      _orders.where((o) => o.status == SupplierOrderStatus.confirmed).length;
  int get deliveredOrders =>
      _orders.where((o) => o.status == SupplierOrderStatus.delivered).length;
  int get cancelledOrders =>
      _orders.where((o) => o.status == SupplierOrderStatus.cancelled).length;

  int get totalOrderAmount =>
      _orders.fold(0, (sum, order) => sum + order.totalAmount);

  SupplierOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SupplierOrder> getOrdersBySupplier(String supplierId) {
    return _orders.where((order) => order.supplierId == supplierId).toList();
  }

  List<SupplierOrder> getOrdersByStatus(SupplierOrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<SupplierOrder> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _orders
        .where(
          (order) =>
              order.orderDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              order.orderDate.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  Future<void> loadOrders() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _orders = [];

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des commandes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrder({
    required String supplierId,
    required String supplierName,
    required List<SupplierOrderItem> items,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final totalAmount = items.fold(0, (sum, item) => sum + item.totalPrice);

      final order = SupplierOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        supplierId: supplierId,
        supplierName: supplierName,
        orderDate: DateTime.now(),
        items: items,
        totalAmount: totalAmount,
        notes: notes,
      );

      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la création de la commande: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    SupplierOrderStatus newStatus,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        DateTime? deliveryDate;
        if (newStatus == SupplierOrderStatus.delivered) {
          deliveryDate = DateTime.now();
        }

        _orders[index] = _orders[index].copyWith(
          status: newStatus,
          deliveryDate: deliveryDate,
        );
        notifyListeners();
      } else {
        throw Exception('Commande non trouvée');
      }
    } catch (e) {
      _setError('Erreur lors de la mise à jour du statut: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrder(SupplierOrder order) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order;
        notifyListeners();
      } else {
        throw Exception('Commande non trouvée');
      }
    } catch (e) {
      _setError(
        'Erreur lors de la mise à jour de la commande: ${e.toString()}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
    } catch (e) {
      _setError(
        'Erreur lors de la suppression de la commande: ${e.toString()}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelOrder(String orderId, String? reason) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: SupplierOrderStatus.cancelled,
          notes: reason ?? 'Commande annulée',
        );
        notifyListeners();
      } else {
        throw Exception('Commande non trouvée');
      }
    } catch (e) {
      _setError('Erreur lors de l\'annulation de la commande: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  List<SupplierOrder> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowerQuery = query.toLowerCase();
    return _orders
        .where(
          (order) =>
              order.supplierName.toLowerCase().contains(lowerQuery) ||
              order.id.toLowerCase().contains(lowerQuery) ||
              order.statusDisplay.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
