import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/invoice_provider.dart';
import '../models/invoice.dart';
import 'invoice_page.dart';
import '../widgets/telegram_page_route.dart';
import '../widgets/settings_dialog.dart';

class InvoicesDialog extends StatelessWidget {
  const InvoicesDialog({super.key});

  static void show(BuildContext context) {
    SettingsDialog.show(context, initialView: 'invoices');
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  String? _paymentStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
    _reload();
  }

  Future<void> _reload() {
    return context.read<InvoiceProvider>().loadInvoices(
      paymentStatus: _paymentStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          // Visual Invoices Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D62).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF2E7D62),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Historique des factures",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Consultez vos reçus d'achat et suivez l'état de vos règlements.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 16),
          if (provider.isLoading && provider.invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'Aucune facture disponible pour le moment.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            )
          else
            ...provider.invoices.map(_buildInvoiceCard),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final formatter = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String?>(
                value: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Paiement',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  DropdownMenuItem(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(value: 'payee', child: Text('Payée')),
                  DropdownMenuItem(value: 'annulee', child: Text('Annulée')),
                ],
                onChanged: (value) {
                  setState(() => _paymentStatus = value);
                  _reload();
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDate(true),
              icon: const Icon(Icons.date_range_rounded, size: 18),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              label: Text(
                _startDate == null
                    ? 'Date début'
                    : formatter.format(_startDate!),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDate(false),
              icon: const Icon(Icons.event_rounded, size: 18),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              label: Text(
                _endDate == null ? 'Date fin' : formatter.format(_endDate!),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (_startDate != null ||
                _endDate != null ||
                _paymentStatus != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _paymentStatus = null;
                  });
                  _reload();
                },
                child: const Text('Réinitialiser'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceRecord invoice) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Commande ${invoice.orderNumber}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(invoice),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatter.format(invoice.invoiceDate),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                Text(
                  invoice.isPickup ? 'Retrait sur place' : 'Livraison',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${invoice.totalAmount.toStringAsFixed(0)} ${invoice.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Color(0xFF2E7D62),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      TelegramPageRoute(
                        child: InvoicePage(initialInvoice: invoice),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D62),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Text('Détail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(InvoiceRecord invoice) {
    Color color;
    switch (invoice.paymentStatus) {
      case 'payee':
        color = Colors.green;
        break;
      case 'annulee':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        invoice.paymentStatusLabel.isNotEmpty
            ? invoice.paymentStatusLabel
            : invoice.paymentStatus,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
