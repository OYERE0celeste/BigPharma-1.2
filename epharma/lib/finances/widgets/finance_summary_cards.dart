import 'package:epharma/providers/finance_provider.dart';
import 'package:epharma/services/finance_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../providers/finance_provider.dart';
//import '../services/finance_service.dart';

class FinanceSummaryCards extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const FinanceSummaryCards({
    required this.startDate,
    required this.endDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final totalRevenue = financeProvider.getTotalRevenue(
      startDate: startDate,
      endDate: endDate,
    );
    final totalExpenses = financeProvider.getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );
    final netProfit = financeProvider.getNetProfit(
      startDate: startDate,
      endDate: endDate,
    );
    final paymentBreakdown = financeProvider.getPaymentMethodBreakdown(
      startDate: startDate,
      endDate: endDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résumé Financier',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryCard(
              '💰 Chiffre d\'affaires total',
              FinanceService.formatAmount(totalRevenue),
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '📉 Total des dépenses',
              FinanceService.formatAmount(totalExpenses),
              Colors.red,
              Icons.trending_down,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '📈 Profit net',
              FinanceService.formatAmount(netProfit),
              netProfit >= 0 ? Colors.green : Colors.red,
              netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '💳 Répartition paiements',
              '${paymentBreakdown.length} méthodes',
              Colors.blue,
              Icons.payment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
