import 'package:epharma/models/sale_model.dart';
import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                        ? 'Filter by Date'
                        : DateFormat('MMM dd, yyyy').format(_selectedDate!),
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
                  label: const Text('Clear Date'),
                ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('Invoice')),
                  DataColumn(label: Text('Date & Time')),
                  DataColumn(label: Text('Total'), numeric: true),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Pharmacist')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredSales.map((sale) {
                  return DataRow(
                    cells: [
                      DataCell(Text(sale.invoiceNumber)),
                      DataCell(
                        Text(
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(sale.dateTime),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${sale.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(sale.paymentMethod)),
                      DataCell(Text(sale.pharmacist)),
                      DataCell(
                        Tooltip(
                          message: 'View Details',
                          child: Icon(
                            Icons.visibility,
                            size: 16,
                            color: kPrimaryGreen,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          if (_filteredSales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No sales history found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
