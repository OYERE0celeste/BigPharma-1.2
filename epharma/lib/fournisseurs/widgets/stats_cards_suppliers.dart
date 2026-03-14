import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';

class StatsCardsSuppliers extends StatelessWidget {
  final bool isMobile;

  const StatsCardsSuppliers({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (context, provider, child) {
        final cards = [
          _StatCard(
            title: 'Total fournisseurs',
            value: provider.totalSuppliers.toString(),
            icon: Icons.business,
            color: Colors.green,
          ),
          _StatCard(
            title: 'Actifs',
            value: provider.activeSuppliers.toString(),
            icon: Icons.check_circle,
            color: Colors.blue,
          ),
          _StatCard(
            title: 'Total commandes',
            value: provider.suppliers.fold<int>(0, (sum, s) => sum + s.totalOrders).toString(),
            icon: Icons.receipt_long,
            color: Colors.orange,
          ),
        ];

        if (isMobile) {
          return Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards.map((card) => Expanded(child: card)).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
