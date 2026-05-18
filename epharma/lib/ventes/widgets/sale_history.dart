import 'package:epharma/models/sale_model.dart';
import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../ventes/services/sales_api_service.dart';
import 'package:epharma/widgets/app_notification.dart';

class SaleHistoryTable extends StatefulWidget {
  final List<Sale> sales;

  const SaleHistoryTable({super.key, required this.sales});

  @override
  State<SaleHistoryTable> createState() => _SaleHistoryTableState();
}

class _SaleHistoryTableState extends State<SaleHistoryTable> {
  late List<Sale> _filteredSales;
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _filteredSales = widget.sales;
  }

  void _updateFilters() {
    _filteredSales = widget.sales.where((sale) {
      if (_selectedDate != null) {
        final saleDate = DateTime(
          sale.dateTime.year,
          sale.dateTime.month,
          sale.dateTime.day,
        );
        final selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        if (saleDate != selectedDate) return false;
      }

      if (_selectedPaymentMethod != null &&
          sale.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      return true;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (selected != null) {
                      setState(() => _selectedDate = selected);
                      _updateFilters();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate == null
                        ? 'Filtrer par date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              if (_selectedDate != null)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _selectedDate = null);
                    _updateFilters();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Effacer la date'),
                ),
            ],
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                        columnSpacing: 24,
                        horizontalMargin: 24,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 64,
                        headingRowHeight: 56,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(label: Text('Facture')),
                          DataColumn(label: Text('Date & Heure')),
                          DataColumn(label: Text('Total'), numeric: true),
                          DataColumn(label: Text('Mode de paiement')),
                          DataColumn(label: Text('Pharmacien')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _filteredSales.map((sale) {
                          return DataRow(
                            cells: [
                              DataCell(Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(sale.dateTime),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${sale.totalAmount.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DataCell(Text(sale.paymentMethod)),
                              DataCell(Text(sale.pharmacist)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: 'Imprimer le ticket',
                                      child: IconButton(
                                        icon: const Icon(Icons.print, size: 20),
                                        color: kPrimaryGreen,
                                        onPressed: () async {
                                          try {
                                            final bytes = await SalesApiService.fetchReceiptPdf(sale.id);
                                            if (bytes != null) {
                                              await Printing.layoutPdf(onLayout: (_) async => bytes);
                                            } else {
                                              if (context.mounted) {
                                                AppScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Impossible de récupérer le reçu.')),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Erreur lors de l\'impression.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Télécharger',
                                      child: IconButton(
                                        icon: const Icon(Icons.download, size: 20),
                                        color: kSoftBlue,
                                        onPressed: () async {
                                          try {
                                            final bytes = await SalesApiService.fetchReceiptPdf(sale.id);
                                            if (bytes != null) {
                                              await Printing.sharePdf(
                                                bytes: bytes,
                                                filename: '${sale.invoiceNumber}.pdf',
                                              );
                                            } else {
                                              if (context.mounted) {
                                                AppScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Impossible de télécharger le reçu.')),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Erreur lors du téléchargement.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_filteredSales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aucun historique de vente trouvé',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
