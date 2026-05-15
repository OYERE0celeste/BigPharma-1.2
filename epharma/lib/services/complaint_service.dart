import 'dart:convert';

import '../models/complaint_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  Future<List<ComplaintModel>> getComplaints({String? status}) async {
    var url = ApiConstants.complaints;
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    final response = await _apiService.get(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des réclamations');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ComplaintModel> updateStatus(
    String complaintId,
    String status,
    String note,
  ) async {
    final response = await _apiService.patch(
      '${ApiConstants.complaints}/$complaintId/status',
      {'status': status, 'note': note},
    );
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        (decoded['message'] ?? 'Mise à jour impossible').toString(),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ComplaintModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
