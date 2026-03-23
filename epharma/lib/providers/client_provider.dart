import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../clients/services/client_api_service.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalClients => _clients.length;

  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _clients = await ClientApiService.getAllClients();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addClient(Client client) async {
    final created = await ClientApiService.createClient(client);
    _clients.insert(0, created);
    notifyListeners();
  }

  Future<void> updateClient(String id, Client client) async {
    final updated = await ClientApiService.updateClient(id, client);
    final index = _clients.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _clients[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteClient(String id) async {
    await ClientApiService.deleteClient(id);
    _clients.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
