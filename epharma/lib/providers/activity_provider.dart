import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities;
  List<ActivityModel> get transactions => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activities = await ActivityService.getAllTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    await ActivityService.addActivity(activity);
    await loadActivities();
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
