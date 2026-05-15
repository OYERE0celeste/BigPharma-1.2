import 'package:flutter/material.dart';

import 'package:client_app/pages/complaints_page.dart';
import 'package:client_app/pages/invoices_page.dart';
import 'package:client_app/pages/orders_page.dart';
import 'package:client_app/pages/reviews_page.dart';

class OrdersPanel extends StatelessWidget {
  const OrdersPanel({super.key, required this.primary});

  final Color primary;

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
              onPressed: () => _open(context, const OrdersPage()),
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
              onPressed: () => _open(context, const InvoicesPage()),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Historique factures'),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary, width: 1.3),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: OutlinedButton.icon(
              onPressed: () => _open(context, const ReviewsPage()),
              icon: const Icon(Icons.star_outline_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Mes avis'),
              ),
            ),
          ),
          SizedBox(
            width: 220,
            child: OutlinedButton.icon(
              onPressed: () => _open(context, const ComplaintsPage()),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Mes réclamations'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
