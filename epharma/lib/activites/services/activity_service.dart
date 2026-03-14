import '../../models/activity_model.dart';

class ActivityService {
  static final List<ActivityModel> _allTransactions = [];

  static List<ActivityModel> getAllTransactions() {
    return List.from(_allTransactions);
  }

  static List<ActivityModel> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _allTransactions
        .where(
          (t) => t.dateTime.isAfter(startDate) && t.dateTime.isBefore(endDate),
        )
        .toList();
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
    final sales = transactions
        .where(
          (t) =>
              t.type == ActivityType.sale &&
              t.status == TransactionStatus.completed,
        )
        .length;

    final totalAmount = transactions
        .where(
          (t) =>
              t.type == ActivityType.sale &&
              t.status == TransactionStatus.completed,
        )
        .fold(0.0, (sum, t) => sum + t.totalAmount);

    return {
      'totalTransactions': transactions.length,
      'totalSales': sales,
      'totalAmount': totalAmount,
    };
  }

  static List<String> getUniqueEmployees(List<ActivityModel> transactions) {
    return transactions
        .map((t) => t.employeeName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  static void addActivity(ActivityModel activity) {
    _allTransactions.insert(0, activity);
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
