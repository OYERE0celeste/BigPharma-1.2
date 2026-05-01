import '../models/activity_model.dart';
import 'activity_api_service.dart';

class ActivityService {
  static Future<List<ActivityModel>> getAllTransactions() async {
    return await ActivityApiService.getAllActivities();
  }

  static Future<List<ActivityModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await ActivityApiService.getActivitiesByRange(startDate, endDate);
  }

  static List<ActivityModel> filterTransactions({
    required List<ActivityModel> transactions,
    ActivityType? type,
    String? employeeName,
    PaymentMethod? paymentMethod,
    String? searchQuery,
  }) {
    return transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (employeeName != null && t.employeeName != employeeName) return false;
      if (paymentMethod != null && t.paymentMethod != paymentMethod) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!t.reference.toLowerCase().contains(q) &&
            !t.clientOrSupplierName.toLowerCase().contains(q) &&
            !t.productName.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  static Map<String, dynamic> getStatistics(List<ActivityModel> transactions) {
    double totalRevenue = 0;
    double totalIncome = 0;
    double totalExpenses = 0;
    int totalProductsSold = 0;
    int transactionCount = transactions.length;

    for (var t in transactions) {
      // Revenu des ventes et commandes complétées
      if ((t.type == ActivityType.sale || t.type == ActivityType.order) &&
          t.status == TransactionStatus.completed) {
        totalRevenue += t.totalAmount;
        totalProductsSold += t.quantity;
      }

      // Flux de trésorerie (Entrées / Sorties)
      if (t.totalAmount > 0) {
        totalIncome += t.totalAmount;
      } else if (t.totalAmount < 0) {
        totalExpenses += t.totalAmount.abs();
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'transactionCount': transactionCount,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'estimatedProfit': totalIncome - totalExpenses, // Updated to use all income/expenses
      'totalProductsSold': totalProductsSold,
    };
  }

  static List<String> getUniqueEmployees(List<ActivityModel> transactions) {
    return transactions
        .map((t) => t.employeeName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  static Future<void> addActivity(ActivityModel activity) async {
    await ActivityApiService.createActivity(activity);
  }

  static List<SalesByDay> getSalesByDay(List<ActivityModel> transactions) {
    final Map<String, double> grouped = {};

    for (var transaction in transactions) {
      if (transaction.type != ActivityType.sale ||
          transaction.status != TransactionStatus.completed) {
        continue;
      }
      final dayKey =
          '${transaction.dateTime.day.toString().padLeft(2, '0')}/${transaction.dateTime.month.toString().padLeft(2, '0')}/${transaction.dateTime.year}';
      grouped[dayKey] = (grouped[dayKey] ?? 0) + transaction.totalAmount;
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries
        .map((entry) => SalesByDay(day: entry.key, amount: entry.value))
        .toList();
  }
}

class SalesByDay {
  final String day;
  final double amount;

  SalesByDay({required this.day, required this.amount});
}
