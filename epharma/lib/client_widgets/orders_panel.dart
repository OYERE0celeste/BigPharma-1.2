import 'package:flutter/material.dart';
import '../pages/client/orders_page.dart';

class OrdersPanel extends StatelessWidget {
  const OrdersPanel({super.key, required this.primary});

  final Color primary;

  void _openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E4DB)),
      ),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: [
          SizedBox(
            width: 250,
            child: FilledButton.icon(
              onPressed: () => _openOrders(context),
              icon: const Icon(Icons.history_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Historique des commandes'),
              ),
              style: FilledButton.styleFrom(backgroundColor: primary),
            ),
          ),
          SizedBox(
            width: 220,
            child: OutlinedButton.icon(
              onPressed: () => _openOrders(context),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Suivre mes commandes'),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary, width: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
