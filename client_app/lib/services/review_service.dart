import 'dart:convert';

import '../models/review_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  Future<(List<ReviewModel>, ReviewSummary)> getProductReviews(
    String productId,
  ) async {
    final response = await _apiService.get(
      '${ApiConstants.reviewsProduct}/$productId',
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des avis');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    final summary = ReviewSummary.fromJson(
      (decoded['extra'] as Map<String, dynamic>?)?['summary']
          as Map<String, dynamic>?,
    );

    return (
      data
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary,
    );
  }

  Future<List<ReviewModel>> getMyReviews() async {
    final response = await _apiService.get(ApiConstants.reviewsMy);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement de vos avis');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> createReview({
    required String productId,
    required int rating,
    String comment = '',
    int? serviceRating,
    String serviceComment = '',
    String dissatisfactionLevel = 'aucune',
    bool wouldRecommend = true,
  }) async {
    final response = await _apiService.post(ApiConstants.reviews, {
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'serviceRating': serviceRating,
      'serviceComment': serviceComment,
      'dissatisfactionLevel': dissatisfactionLevel,
      'wouldRecommend': wouldRecommend,
    });

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(
        (decoded['message'] ?? 'Impossible d\'enregistrer cet avis').toString(),
      );
    }

    return ReviewModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
