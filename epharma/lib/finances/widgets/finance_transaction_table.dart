import 'package:flutter/material.dart';

import 'package:epharma/models/finance_model.dart';
import 'package:epharma/services/finance_service.dart';
import 'package:epharma/widgets/app_notification.dart';

import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_table_controls.dart';

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
    final startIndex = (currentPage * rowsPerPage).clamp(
      0,
      transactions.length,
    );
    final endIndex = (startIndex + rowsPerPage).clamp(0, transactions.length);
    final displayedTransactions = transactions.sublist(startIndex, endIndex);
    final totalPages = transactions.isEmpty
        ? 1
        : (transactions.length / rowsPerPage).ceil();
    final visibleStart = displayedTransactions.isEmpty ? 0 : startIndex + 1;
    final visibleEnd = displayedTransactions.isEmpty ? 0 : startIndex + displayedTransactions.length;
    final summary = transactions.isEmpty
        ? 'Aucune transaction à afficher'
        : 'Affichage de $visibleStart à $visibleEnd sur ${transactions.length} transactions';

    return BpSurfaceCard(
      padding: EdgeInsets.zero,
      radius: BpSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Flux financiers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BpColors.textPrimary,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : 0.0,
                  ),
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    headingRowColor: WidgetStateProperty.all(
                      BpColors.surfaceMuted,
                    ),
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 64,
                    headingRowHeight: 56,
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Référence',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Source',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Description',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Montant',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        numeric: true,
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Entrée/Sortie',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Mode paiement',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Employé',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                        onSort: onSort,
                      ),
                      DataColumn(
                        label: Text(
                          'Action',
                          style: TextStyle(color: BpColors.textPrimary),
                        ),
                      ),
                    ],
                    rows: displayedTransactions.map((transaction) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              FinanceService.formatDate(transaction.dateTime),
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              transaction.type,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              transaction.reference,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              transaction.sourceModule,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              transaction.description,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              FinanceService.formatAmount(transaction.amount),
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
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
                          DataCell(
                            Text(
                              transaction.paymentMethod,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              transaction.employeeName,
                              style: TextStyle(
                                color: BpColors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: BpColors.textPrimary,
                              ),
                              onPressed: () {
                                if (onViewDetails != null) {
                                  onViewDetails!(transaction);
                                } else {
                                  AppScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
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
          AppTableFooter(
            summary: summary,
            pager: AppTablePager(
              currentPage: currentPage,
              totalPages: totalPages,
              onPrevious: onPreviousPage,
              onNext: onNextPage,
            ),
          ),
        ],
      ),
    );
  }
}
