import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/invoice_provider.dart';
import '../models/invoice.dart';
import 'invoice_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Historique des factures'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.invoices.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.invoices.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(
                  child: Text('Aucune facture disponible pour le moment.'),
                ),
              )
            else
              ...provider.invoices.map(_buildInvoiceCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final formatter = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Paiement',
                  border: OutlineInputBorder(),
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
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                _startDate == null
                    ? 'Date début'
                    : formatter.format(_startDate!),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDate(false),
              icon: const Icon(Icons.event_outlined),
              label: Text(
                _endDate == null ? 'Date fin' : formatter.format(_endDate!),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Commande ${invoice.orderNumber}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(invoice),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              formatter.format(invoice.invoiceDate),
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '${invoice.totalAmount.toStringAsFixed(0)} ${invoice.currency}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              invoice.isPickup ? 'Retrait sur place' : 'Livraison',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoicePage(initialInvoice: invoice),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Détail de facture'),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        invoice.paymentStatusLabel.isNotEmpty
            ? invoice.paymentStatusLabel
            : invoice.paymentStatus,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
