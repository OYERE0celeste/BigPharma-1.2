import 'dart:convert';

import '../models/review_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  Future<List<ReviewModel>> getReviews({
    bool dissatisfactionOnly = false,
  }) async {
    var url = ApiConstants.reviews;
    if (dissatisfactionOnly) {
      url += '?dissatisfactionOnly=true';
    }

    final response = await _apiService.get(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des avis');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> respondToReview(String reviewId, String message) async {
    final response = await _apiService.patch(
      '${ApiConstants.reviews}/$reviewId/response',
      {'message': message},
    );
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception((decoded['message'] ?? 'Réponse impossible').toString());
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
