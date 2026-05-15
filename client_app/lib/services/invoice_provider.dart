import 'package:flutter/material.dart';

import '../models/invoice.dart';
import 'invoice_service.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceService _service = InvoiceService();

  List<InvoiceRecord> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceRecord> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvoices({
    String? paymentStatus,
    String? orderStatus,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _service.getMyInvoices(
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
        search: search,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
