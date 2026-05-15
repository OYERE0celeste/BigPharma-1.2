import 'package:flutter/material.dart';

import '../models/complaint_model.dart';
import 'complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _service = ComplaintService();

  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadComplaints({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _complaints = await _service.getMyComplaints(status: status);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ComplaintModel> createComplaint({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    String? productId,
  }) async {
    final complaint = await _service.createComplaint(
      category: category,
      subject: subject,
      description: description,
      orderId: orderId,
      productId: productId,
    );
    _complaints.insert(0, complaint);
    notifyListeners();
    return complaint;
  }
}
