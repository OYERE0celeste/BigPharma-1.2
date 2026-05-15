import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/order.dart';
import '../services/invoice_service.dart';

class InvoicePage extends StatefulWidget {
  final Order? order;
  final InvoiceRecord? initialInvoice;

  const InvoicePage({super.key, this.order, this.initialInvoice});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final InvoiceService _service = InvoiceService();
  InvoiceRecord? _invoice;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPdfBusy = false;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.initialInvoice != null) {
        _invoice = widget.initialInvoice;
      } else if (widget.order != null) {
        _invoice = await _service.getOrderInvoice(widget.order!.id);
      } else {
        throw Exception('Aucune facture à afficher.');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _printInvoice() async {
    final invoice = _invoice;
    if (invoice == null) return;

    setState(() => _isPdfBusy = true);
    try {
      final bytes = await _service.fetchInvoicePdf(invoice.id);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isPdfBusy = false);
      }
    }
  }

  Future<void> _shareInvoice() async {
    final invoice = _invoice;
    if (invoice == null) return;

    setState(() => _isPdfBusy = true);
    try {
      final bytes = await _service.fetchInvoicePdf(invoice.id);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isPdfBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_BJ',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma facture électronique'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(primary, currencyFormat),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Facture indisponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadInvoice,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color primary, NumberFormat currencyFormat) {
    final invoice = _invoice!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'CODE DE RETRAIT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  invoice.hasCollectionCode ? invoice.collectionCode : '------',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  invoice.isPickup
                      ? 'Présentez ce code à la pharmacie pour récupérer vos articles.'
                      : 'Conservez cette référence pour le suivi de votre livraison.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'FACTURE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusChip(
                        invoice.paymentStatusLabel.isNotEmpty
                            ? invoice.paymentStatusLabel
                            : invoice.paymentStatus,
                        invoice.paymentStatus == 'payee'
                            ? Colors.green
                            : invoice.paymentStatus == 'annulee'
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow('N° Facture', invoice.invoiceNumber),
                  _buildInfoRow('N° Commande', invoice.orderNumber),
                  _buildInfoRow(
                    'Date',
                    DateFormat('dd/MM/yyyy HH:mm').format(invoice.invoiceDate),
                  ),
                  _buildInfoRow(
                    'Mode de retrait',
                    invoice.isPickup ? 'Sur place' : 'Livraison',
                  ),
                  _buildInfoRow(
                    'Statut commande',
                    invoice.orderStatusLabel.isNotEmpty
                        ? invoice.orderStatusLabel
                        : invoice.orderStatus,
                  ),
                  const Divider(height: 32),
                  const Text(
                    'ARTICLES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...invoice.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.total),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormat.format(invoice.totalAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isPdfBusy ? null : _printInvoice,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Imprimer'),
                ),
                OutlinedButton.icon(
                  onPressed: _isPdfBusy ? null : _shareInvoice,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Télécharger PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
