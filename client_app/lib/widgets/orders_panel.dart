import 'package:flutter/material.dart';

import 'package:client_app/pages/invoices_page.dart';
import 'package:client_app/pages/orders_page.dart';
import 'package:client_app/pages/relation_client_page.dart';
import 'package:client_app/widgets/telegram_page_route.dart';

import 'bp_theme.dart';

class OrdersPanel extends StatelessWidget {
  const OrdersPanel({super.key, required this.primary});

  final Color primary;

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, TelegramPageRoute(child: page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BpColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BpColors.border),
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
              onPressed: () => InvoicesDialog.show(context),
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
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () => _open(context, const RelationClientPage(initialIndex: 0)),
              icon: const Icon(Icons.support_agent_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Relation Client'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
