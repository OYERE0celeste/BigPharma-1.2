import 'package:epharma/providers/finance_provider.dart';
import 'package:epharma/services/finance_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/bp_theme.dart';
import '../../widgets/page_stat_cards.dart';

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
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
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
        const Text('Résumé des entrées', style: BpTextStyles.heading2),
        const SizedBox(height: 16),
        PageStatCards(
          items: [
            PageStatCardData(
              label: 'Chiffre d\'affaires total',
              value: FinanceService.formatAmount(totalRevenue),
              color: Colors.green,
              icon: Icons.account_balance_wallet,
            ),
            PageStatCardData(
              label: 'Nombre de transactions',
              value: '$transactionCount ventes',
              color: Colors.blue,
              icon: Icons.shopping_cart,
            ),
            PageStatCardData(
              label: 'Panier moyen',
              value: FinanceService.formatAmount(averageBasket),
              color: Colors.orange,
              icon: Icons.analytics,
            ),
            PageStatCardData(
              label: 'Répartition paiements',
              value: '${paymentBreakdown.length} méthodes',
              color: Colors.purple,
              icon: Icons.payment,
            ),
          ],
        ),
      ],
    );
  }
}
