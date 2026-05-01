import 'package:flutter/material.dart';

class StockForecastWidget extends StatelessWidget {
  final int currentStock;
  final int monthlyAvgSales;

  const StockForecastWidget({
    super.key,
    required this.currentStock,
    required this.monthlyAvgSales,
  });

  @override
  Widget build(BuildContext context) {
    final monthsLeft = monthlyAvgSales > 0 ? (currentStock / monthlyAvgSales).toStringAsFixed(1) : '∞';
    final isLow = monthlyAvgSales > 0 && (currentStock / monthlyAvgSales) < 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLow ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLow ? Colors.red[200]! : Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, color: isLow ? Colors.red : Colors.blue),
              const SizedBox(width: 8),
              const Text('Prévision de Stock', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Basé sur vos ventes moyennes ($monthlyAvgSales/mois), votre stock actuel durera environ $monthsLeft mois.',
            style: const TextStyle(fontSize: 13),
          ),
          if (isLow)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '⚠️ Attention : Réapprovisionnement urgent recommandé.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
