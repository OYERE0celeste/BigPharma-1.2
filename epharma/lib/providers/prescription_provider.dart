import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/api_constants.dart';
import 'auth_provider.dart';

class PrescriptionProvider with ChangeNotifier {
  List<OrderModel> _pendingPrescriptions = [];
  List<OrderModel> _validatedPrescriptions = [];
  List<OrderModel> _rejectedPrescriptions = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _stats = {'pending': 0, 'validated': 0, 'rejected': 0};

  List<OrderModel> get pendingPrescriptions => _pendingPrescriptions;
  List<OrderModel> get validatedPrescriptions => _validatedPrescriptions;
  List<OrderModel> get rejectedPrescriptions => _rejectedPrescriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get stats => _stats;

  Future<void> loadPrescriptions({
    required AuthProvider authProvider,
    String status = 'pending',
    bool forceRefresh = false,
  }) async {
    final token = authProvider.token;
    if (token == null) return;

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.prescriptions}?status=$status&limit=50'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final items = (data['data'] as List)
              .map((json) => OrderModel.fromJson(json))
              .toList();

          if (status == 'pending') {
            _pendingPrescriptions = items;
          } else if (status == 'validated') {
            _validatedPrescriptions = items;
          } else if (status == 'rejected') {
            _rejectedPrescriptions = items;
          }
          
          if (data['stats'] != null) {
            _stats = Map<String, int>.from(data['stats']);
          }
        } else {
          _errorMessage = data['message'] ?? 'Erreur lors du chargement des ordonnances';
        }
      } else {
        _errorMessage = 'Erreur serveur: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validatePrescription({
    required String orderId,
    required String token,
    String? notes,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.prescriptions.replaceFirst('/prescriptions', '')}/$orderId/prescription/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'pharmacistNotes': notes}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        _pendingPrescriptions.removeWhere((p) => p.id == orderId);
        _stats['pending'] = (_stats['pending'] ?? 1) - 1;
        _stats['validated'] = (_stats['validated'] ?? 0) + 1;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectPrescription({
    required String orderId,
    required String token,
    required String reason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.prescriptions.replaceFirst('/prescriptions', '')}/$orderId/prescription/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rejectionReason': reason}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        _pendingPrescriptions.removeWhere((p) => p.id == orderId);
        _stats['pending'] = (_stats['pending'] ?? 1) - 1;
        _stats['rejected'] = (_stats['rejected'] ?? 0) + 1;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
