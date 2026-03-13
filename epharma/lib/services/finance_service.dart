import 'package:intl/intl.dart';
import '../models/finance_model.dart';

/// Service centralisé pour la gestion des finances
class FinanceService {
  // Instance singleton
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  // Données mockées pour simulation
  List<FinanceTransactionModel> _transactions = [];

  // Initialisation des données mockées
  void initializeMockData() {
    _transactions = [];
  }

  // Récupérer toutes les transactions
  List<FinanceTransactionModel> getAllTransactions() {
    return List.from(_transactions);
  }

  // Récupérer transactions filtrées
  List<FinanceTransactionModel> getFilteredTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? paymentMethod,
    String? employeeName,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) {
    return _transactions.where((transaction) {
      if (startDate != null && transaction.dateTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.dateTime.isAfter(endDate)) {
        return false;
      }
      if (type != null && transaction.type != type) return false;
      if (paymentMethod != null && transaction.paymentMethod != paymentMethod) {
        return false;
      }
      if (employeeName != null && transaction.employeeName != employeeName) {
        return false;
      }
      if (minAmount != null && transaction.amount < minAmount) return false;
      if (maxAmount != null && transaction.amount > maxAmount) return false;
      if (searchQuery != null &&
          !transaction.description.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) &&
          !transaction.reference.toLowerCase().contains(
            searchQuery.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();
  }

  // Calculs financiers
  double getTotalRevenue({DateTime? startDate, DateTime? endDate}) {
    final filtered = getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    return filtered
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    final filtered = getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    return filtered
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getNetProfit({DateTime? startDate, DateTime? endDate}) {
    return getTotalRevenue(startDate: startDate, endDate: endDate) -
        getTotalExpenses(startDate: startDate, endDate: endDate);
  }

  // Répartition par mode de paiement
  Map<String, double> getPaymentMethodBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    final breakdown = <String, double>{};
    for (final transaction in filtered) {
      breakdown[transaction.paymentMethod] =
          (breakdown[transaction.paymentMethod] ?? 0) + transaction.amount;
    }
    return breakdown;
  }

  List<Map<String, dynamic>> getRevenueVsExpensesData({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    final groupedByDate = <DateTime, Map<String, double>>{};

    for (final transaction in filtered) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      groupedByDate[date] ??= {'revenue': 0.0, 'expenses': 0.0};
      if (transaction.isIncome) {
        groupedByDate[date]!['revenue'] =
            groupedByDate[date]!['revenue']! + transaction.amount;
      } else {
        groupedByDate[date]!['expenses'] =
            groupedByDate[date]!['expenses']! + transaction.amount;
      }
    }

    return groupedByDate.entries.map((entry) {
      return {
        'date': entry.key,
        'revenue': entry.value['revenue']!,
        'expenses': entry.value['expenses']!,
      };
    }).toList()..sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
  }

  void addTransaction(FinanceTransactionModel transaction) {
    _transactions.insert(0, transaction);
  }

  // Formatage des montants
  static String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    return formatter.format(amount);
  }

  // Formatage des dates
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
