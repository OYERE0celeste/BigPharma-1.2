import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  static const Duration _cacheDuration = Duration(minutes: 2);

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  DateTime? _lastLoadedAt;
  Future<void>? _pendingLoad;

  List<ActivityModel> get activities => _activities;
  List<ActivityModel> get transactions => _activities;
  bool get isLoading => _isLoading;

  bool get hasFreshData =>
      _activities.isNotEmpty &&
      _lastLoadedAt != null &&
      DateTime.now().difference(_lastLoadedAt!) < _cacheDuration;

  Future<void> loadActivities({bool forceRefresh = false}) async {
    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (!forceRefresh && hasFreshData) {
      return;
    }

    final shouldShowLoader = _activities.isEmpty;
    if (shouldShowLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _pendingLoad = _loadActivitiesInternal(shouldShowLoader: shouldShowLoader);
    return _pendingLoad!;
  }

  Future<void> _loadActivitiesInternal({required bool shouldShowLoader}) async {
    try {
      _activities = await ActivityService.getAllTransactions();
      _lastLoadedAt = DateTime.now();
    } finally {
      _pendingLoad = null;
      if (shouldShowLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    await ActivityService.addActivity(activity);
    _lastLoadedAt = null;
    await loadActivities(forceRefresh: true);
  }

  Future<List<ActivityModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await ActivityService.getTransactionsByDateRange(startDate, endDate);
  }

  List<ActivityModel> filterTransactions({
    List<ActivityModel>? transactions,
    ActivityType? type,
    String? employeeName,
    PaymentMethod? paymentMethod,
    String? searchQuery,
  }) {
    return ActivityService.filterTransactions(
      transactions: transactions ?? activities,
      type: type,
      employeeName: employeeName,
      paymentMethod: paymentMethod,
      searchQuery: searchQuery,
    );
  }

  Map<String, dynamic> getStatistics() {
    return ActivityService.getStatistics(activities);
  }
}
