import 'package:flutter/foundation.dart';
import '../models/supplier_model.dart';
import '../fournisseurs/services/supplier_api_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalSuppliers => _suppliers.length;
  int get activeSuppliers =>
      _suppliers.where((s) => s.status == SupplierStatus.active).length;
  int get inactiveSuppliers =>
      _suppliers.where((s) => s.status == SupplierStatus.inactive).length;
  int get suspendedSuppliers =>
      _suppliers.where((s) => s.status == SupplierStatus.suspended).length;

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Supplier> getSuppliersByStatus(SupplierStatus status) {
    return _suppliers.where((supplier) => supplier.status == status).toList();
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;

    final lowerQuery = query.toLowerCase();
    return _suppliers
        .where(
          (supplier) =>
              supplier.name.toLowerCase().contains(lowerQuery) ||
              supplier.contactName.toLowerCase().contains(lowerQuery) ||
              supplier.email.toLowerCase().contains(lowerQuery) ||
              supplier.phone.toLowerCase().contains(lowerQuery) ||
              supplier.city.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  Future<void> loadSuppliers() async {
    _setLoading(true);
    _clearError();

    try {
      _suppliers = await SupplierApiService.getAllSuppliers();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des fournisseurs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addSupplier({
    required String name,
    required String contactName,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String country,
    String notes = '',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final supplier = SupplierApiService.createSupplierFromForm(
        name: name,
        contactName: contactName,
        phone: phone,
        email: email,
        address: address,
        city: city,
        country: country,
        notes: notes,
      );

      // Validation des données
      if (!SupplierApiService.validateSupplierData(supplier)) {
        throw Exception(
          'Veuillez vérifier les données du formulaire (email et téléphone invalides)',
        );
      }

      final createdSupplier = await SupplierApiService.createSupplier(supplier);
      _suppliers.add(createdSupplier);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'ajout du fournisseur: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    _setLoading(true);
    _clearError();

    try {
      // Validation des données
      if (!SupplierApiService.validateSupplierData(supplier)) {
        throw Exception(
          'Veuillez vérifier les données du formulaire (email et téléphone invalides)',
        );
      }

      final updatedSupplier = await SupplierApiService.updateSupplier(supplier);
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
        notifyListeners();
      } else {
        throw Exception('Fournisseur non trouvé');
      }
    } catch (e) {
      _setError(
        'Erreur lors de la mise à jour du fournisseur: ${e.toString()}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    _setLoading(true);
    _clearError();

    try {
      await SupplierApiService.deleteSupplier(supplierId);
      _suppliers.removeWhere((s) => s.id == supplierId);
      notifyListeners();
    } catch (e) {
      _setError(
        'Erreur lors de la suppression du fournisseur: ${e.toString()}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSupplierStatus(
    String supplierId,
    SupplierStatus newStatus,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _suppliers.indexWhere((s) => s.id == supplierId);
      if (index != -1) {
        _suppliers[index] = _suppliers[index].copyWith(status: newStatus);
        notifyListeners();
      } else {
        throw Exception('Fournisseur non trouvé');
      }
    } catch (e) {
      _setError('Erreur lors de la mise à jour du statut: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrderToSupplier(String supplierId, int orderAmount) async {
    final supplier = getSupplierById(supplierId);
    if (supplier != null) {
      final updatedSupplier = supplier.addOrder(orderAmount);
      await updateSupplier(updatedSupplier);
    }
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

  void clearSuppliers() {
    _suppliers.clear();
    notifyListeners();
  }
}
