import 'package:flutter/material.dart';
import '../models/finance_model.dart';
import '../services/finance_service.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceService _financeService = FinanceService();

  List<FinanceTransactionModel> get transactions =>
      _financeService.getAllTransactions();

  double get totalRevenue => _financeService.getTotalRevenue();
  double get totalExpenses => _financeService.getTotalExpenses();
  double get netProfit => _financeService.getNetProfit();

  double getTotalRevenue({DateTime? startDate, DateTime? endDate}) =>
      _financeService.getTotalRevenue(startDate: startDate, endDate: endDate);
  double getTotalExpenses({DateTime? startDate, DateTime? endDate}) =>
      _financeService.getTotalExpenses(startDate: startDate, endDate: endDate);
  double getNetProfit({DateTime? startDate, DateTime? endDate}) =>
      _financeService.getNetProfit(startDate: startDate, endDate: endDate);

  void initialize() {
    _financeService.initializeMockData();
    notifyListeners();
  }

  void addTransaction(FinanceTransactionModel transaction) {
    _financeService.addTransaction(transaction);
    notifyListeners();
  }

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
    return _financeService.getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
      type: type,
      paymentMethod: paymentMethod,
      employeeName: employeeName,
      minAmount: minAmount,
      maxAmount: maxAmount,
      searchQuery: searchQuery,
    );
  }

  List<Map<String, dynamic>> getRevenueVsExpensesData({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _financeService.getRevenueVsExpensesData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Map<String, double> getPaymentMethodBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _financeService.getPaymentMethodBreakdown(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
