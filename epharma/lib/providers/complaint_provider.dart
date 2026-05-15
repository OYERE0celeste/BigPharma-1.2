import 'package:flutter/material.dart';

import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _service = ComplaintService();

  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;
  String? _error;

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadComplaints({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _service.getComplaints(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    String complaintId,
    String status,
    String note,
  ) async {
    final updated = await _service.updateStatus(complaintId, status, note);
    final index = _complaints.indexWhere(
      (complaint) => complaint.id == complaintId,
    );
    if (index != -1) {
      _complaints[index] = updated;
      notifyListeners();
    }
  }
}
