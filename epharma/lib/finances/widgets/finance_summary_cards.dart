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
    final incomeTransactions = financeProvider.getFilteredTransactions(
      startDate: startDate,
      endDate: endDate,
      type: 'Vente',
    );
    final totalRevenue = financeProvider.getTotalRevenue(
      startDate: startDate,
      endDate: endDate,
    );
    final transactionCount = incomeTransactions.length;
    final averageBasket = transactionCount > 0 ? totalRevenue / transactionCount : 0.0;
    
    final paymentBreakdown = financeProvider.getPaymentMethodBreakdown(
      startDate: startDate,
      endDate: endDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résumé des Entrées',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryCard(
              '💰 Chiffre d\'affaires total',
              FinanceService.formatAmount(totalRevenue),
              Colors.green,
              Icons.account_balance_wallet,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '📊 Nombre de transactions',
              '$transactionCount ventes',
              Colors.blue,
              Icons.shopping_cart,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '🎯 Panier moyen',
              FinanceService.formatAmount(averageBasket),
              Colors.orange,
              Icons.analytics,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '💳 Répartition paiements',
              '${paymentBreakdown.length} méthodes',
              Colors.purple,
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
