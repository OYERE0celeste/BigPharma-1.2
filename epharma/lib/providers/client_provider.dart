import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../clients/services/client_api_service.dart';

class ClientProvider with ChangeNotifier {
  static const Duration _cacheDuration = Duration(minutes: 2);

  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoadedAt;
  Future<void>? _pendingLoad;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalClients => _clients.length;

  bool get hasFreshData =>
      _clients.isNotEmpty &&
      _lastLoadedAt != null &&
      DateTime.now().difference(_lastLoadedAt!) < _cacheDuration;

  Future<void> loadClients({bool forceRefresh = false}) async {
    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (!forceRefresh && hasFreshData) {
      return;
    }

    final shouldShowLoader = _clients.isEmpty;
    _error = null;
    if (shouldShowLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _pendingLoad = _loadClientsInternal(shouldShowLoader: shouldShowLoader);
    return _pendingLoad!;
  }

  Future<void> _loadClientsInternal({required bool shouldShowLoader}) async {
    try {
      _clients = await ClientApiService.getAllClients();
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _pendingLoad = null;
      if (shouldShowLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> addClient(Client client) async {
    final created = await ClientApiService.createClient(client);
    _clients.insert(0, created);
    _lastLoadedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> updateClient(String id, Client client) async {
    final updated = await ClientApiService.updateClient(id, client);
    final index = _clients.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _clients[index] = updated;
      _lastLoadedAt = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> deleteClient(String id) async {
    await ClientApiService.deleteClient(id);
    _clients.removeWhere((c) => c.id == id);
    _lastLoadedAt = DateTime.now();
    notifyListeners();
  }
}
