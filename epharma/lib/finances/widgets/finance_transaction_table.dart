import 'package:epharma/models/finance_model.dart';
//import 'package:epharma/products/pharmacy_products_page.dart' ;
import 'package:epharma/services/finance_service.dart';
import 'package:flutter/material.dart';
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
    final startIndex = currentPage * rowsPerPage;
    final endIndex = (currentPage + 1) * rowsPerPage;
    final displayedTransactions = transactions.sublist(
      startIndex,
      endIndex > transactions.length ? transactions.length : endIndex,
    );

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Flux Financiers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              columns: [
                DataColumn(label: const Text('Date'), onSort: onSort),
                DataColumn(label: const Text('Type'), onSort: onSort),
                DataColumn(label: const Text('Référence'), onSort: onSort),
                DataColumn(label: const Text('Source'), onSort: onSort),
                DataColumn(label: const Text('Description'), onSort: onSort),
                DataColumn(
                  label: const Text('Montant'),
                  numeric: true,
                  onSort: onSort,
                ),
                DataColumn(label: const Text('Entrée/Sortie'), onSort: onSort),
                DataColumn(label: const Text('Mode paiement'), onSort: onSort),
                DataColumn(label: const Text('Employé'), onSort: onSort),
                const DataColumn(label: Text('Action')),
              ],
              rows: displayedTransactions.map((transaction) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(FinanceService.formatDate(transaction.dateTime)),
                    ),
                    DataCell(Text(transaction.type)),
                    DataCell(Text(transaction.reference)),
                    DataCell(Text(transaction.sourceModule)),
                    DataCell(Text(transaction.description)),
                    DataCell(
                      Text(FinanceService.formatAmount(transaction.amount)),
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
                    DataCell(Text(transaction.paymentMethod)),
                    DataCell(Text(transaction.employeeName)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          if (onViewDetails != null) {
                            onViewDetails!(transaction);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
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
          Text('$totalCount transactions'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? onPrevious : null,
              ),
              Text('${currentPage + 1}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
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
