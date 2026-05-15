import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviews({bool dissatisfactionOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _service.getReviews(
        dissatisfactionOnly: dissatisfactionOnly,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToReview(String reviewId, String message) async {
    final updated = await _service.respondToReview(reviewId, message);
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index != -1) {
      _reviews[index] = updated;
      notifyListeners();
    }
  }
}
