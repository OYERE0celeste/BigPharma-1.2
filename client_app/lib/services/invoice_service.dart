import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice.dart';
import 'api_constants.dart';
import 'api_service.dart';

class InvoiceService {
  final ApiService _apiService = ApiService();

  Future<List<InvoiceRecord>> getMyInvoices({
    String? paymentStatus,
    String? orderStatus,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String>[];
    if (paymentStatus != null && paymentStatus.isNotEmpty) {
      params.add('paymentStatus=$paymentStatus');
    }
    if (orderStatus != null && orderStatus.isNotEmpty) {
      params.add('orderStatus=$orderStatus');
    }
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (startDate != null) {
      params.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      params.add('endDate=${endDate.toIso8601String()}');
    }

    var url = ApiConstants.invoicesMy;
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await _apiService.get(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des factures');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => InvoiceRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<InvoiceRecord> getInvoiceById(String id) async {
    final response = await _apiService.get('${ApiConstants.invoices}/$id');
    if (response.statusCode != 200) {
      throw Exception('Facture introuvable');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return InvoiceRecord.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<InvoiceRecord> getOrderInvoice(String orderId) async {
    final response = await _apiService.get(
      '${ApiConstants.orders}/$orderId/invoice',
    );
    if (response.statusCode != 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(
        (decoded['message'] ?? 'Facture indisponible pour cette commande')
            .toString(),
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return InvoiceRecord.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<Uint8List> fetchInvoicePdf(String invoiceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    final response = await http.get(
      Uri.parse('${ApiConstants.invoices}/$invoiceId/pdf'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/pdf',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Impossible de récupérer le PDF');
    }

    return response.bodyBytes;
  }
}
