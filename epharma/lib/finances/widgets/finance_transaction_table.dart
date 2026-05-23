import 'package:epharma/models/finance_model.dart';
//import 'package:epharma/products/pharmacy_products_page.dart' ;
import 'package:epharma/services/finance_service.dart';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import '../../widgets/bp_theme.dart';
//import '../models/finance_model.dart';
//import '../services/finance_service.dart';

class FinanceTransactionTable extends StatelessWidget {
  final List<FinanceTransactionModel> transactions;
  final int currentPage;
  final int rowsPerPage;
  final int sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool) onSort;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final void Function(FinanceTransactionModel)? onViewDetails;

  const FinanceTransactionTable({
    required this.transactions,
    required this.currentPage,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    this.onPreviousPage,
    this.onNextPage,
    this.onViewDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp indices to avoid RangeError when data shrinks or page is out of bounds
    final startIndex = (currentPage * rowsPerPage).clamp(0, transactions.length);
    final endIndex = (startIndex + rowsPerPage).clamp(0, transactions.length);
    final displayedTransactions = transactions.sublist(startIndex, endIndex);

    return Card(
      elevation: 4,
      color: BpColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Flux Financiers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BpColors.textPrimary),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0,
                  ),
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    headingRowColor: WidgetStateProperty.all(BpColors.surface),
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 64,
                    headingRowHeight: 56,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
                    columns: [
                DataColumn(label: const Text('Date', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Type', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Référence', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Source', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Description', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(
                  label: const Text('Montant', style: TextStyle(color: BpColors.textPrimary)),
                  numeric: true,
                  onSort: onSort,
                ),
                DataColumn(label: const Text('Entrée/Sortie', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Mode paiement', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                DataColumn(label: const Text('Employé', style: TextStyle(color: BpColors.textPrimary)), onSort: onSort),
                const DataColumn(label: Text('Action', style: TextStyle(color: BpColors.textPrimary))),
              ],
              rows: displayedTransactions.map((transaction) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(FinanceService.formatDate(transaction.dateTime), style: const TextStyle(color: BpColors.textSecondary)),
                    ),
                    DataCell(Text(transaction.type, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(Text(transaction.reference, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(Text(transaction.sourceModule, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(Text(transaction.description, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(
                      Text(FinanceService.formatAmount(transaction.amount), style: const TextStyle(color: BpColors.textSecondary)),
                    ),
                    DataCell(
                      Text(
                        transaction.isIncome ? 'Entrée' : 'Sortie',
                        style: TextStyle(
                          color: transaction.isIncome
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(Text(transaction.paymentMethod, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(Text(transaction.employeeName, style: const TextStyle(color: BpColors.textSecondary))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility, color: BpColors.textPrimary),
                        onPressed: () {
                          if (onViewDetails != null) {
                            onViewDetails!(transaction);
                          } else {
                            AppScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Détails de ${transaction.reference}',
                                ),
                              ),
                            );
                          }
                        },
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
    _PaginationControls(
            totalCount: transactions.length,
            currentPage: currentPage,
            rowsPerPage: rowsPerPage,
            onPrevious: onPreviousPage,
            onNext: onNextPage,
          ),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int totalCount;
  final int currentPage;
  final int rowsPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationControls({
    required this.totalCount,
    required this.currentPage,
    required this.rowsPerPage,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$totalCount transactions', style: const TextStyle(color: BpColors.textSecondary)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: BpColors.textPrimary),
                onPressed: currentPage > 0 ? onPrevious : null,
              ),
              Text('${currentPage + 1}', style: const TextStyle(color: BpColors.textPrimary, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: BpColors.textPrimary),
                onPressed: (currentPage + 1) * rowsPerPage < totalCount
                    ? onNext
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
