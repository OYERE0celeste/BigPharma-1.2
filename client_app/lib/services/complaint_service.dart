import 'dart:convert';

import '../models/complaint_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  Future<List<ComplaintModel>> getMyComplaints({String? status}) async {
    var url = ApiConstants.complaintsMy;
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    final response = await _apiService.get(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des réclamations');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ComplaintModel> createComplaint({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    String? productId,
  }) async {
    final response = await _apiService.post(ApiConstants.complaints, {
      'category': category,
      'subject': subject,
      'description': description,
      if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
      if (productId != null && productId.isNotEmpty) 'productId': productId,
    });
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(
        (decoded['message'] ?? 'Impossible de soumettre la réclamation')
            .toString(),
      );
    }

    return ComplaintModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
