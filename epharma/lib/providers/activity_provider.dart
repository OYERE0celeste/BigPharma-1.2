import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../activites/services/activity_service.dart';

class ActivityProvider with ChangeNotifier {

  List<ActivityModel> get activities => ActivityService.getAllTransactions();
  List<ActivityModel> get transactions => ActivityService.getAllTransactions();

  void addActivity(ActivityModel activity) {
    ActivityService.addActivity(activity);
    notifyListeners();
  }

  List<ActivityModel> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return ActivityService.getTransactionsByDateRange(startDate, endDate);
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
