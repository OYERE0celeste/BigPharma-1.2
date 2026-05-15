import 'package:flutter/material.dart';

import '../models/review_model.dart';
import 'review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();

  final Map<String, List<ReviewModel>> _productReviews = {};
  final Map<String, ReviewSummary> _productSummaries = {};
  List<ReviewModel> _myReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReviewModel> get myReviews => _myReviews;

  List<ReviewModel> reviewsForProduct(String productId) =>
      _productReviews[productId] ?? const [];

  ReviewSummary summaryForProduct(String productId) =>
      _productSummaries[productId] ??
      const ReviewSummary(
        averageRating: 0,
        averageServiceRating: 0,
        total: 0,
        dissatisfactionCount: 0,
      );

  Future<void> loadProductReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (reviews, summary) = await _service.getProductReviews(productId);
      _productReviews[productId] = reviews;
      _productSummaries[productId] = summary;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myReviews = await _service.getMyReviews();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewModel> submitReview({
    required String productId,
    required int rating,
    String comment = '',
    int? serviceRating,
    String serviceComment = '',
    String dissatisfactionLevel = 'aucune',
    bool wouldRecommend = true,
  }) async {
    final review = await _service.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
      serviceRating: serviceRating,
      serviceComment: serviceComment,
      dissatisfactionLevel: dissatisfactionLevel,
      wouldRecommend: wouldRecommend,
    );
    await loadProductReviews(productId);
    await loadMyReviews();
    return review;
  }
}
