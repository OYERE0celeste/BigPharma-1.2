import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import '../models/finance_model.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../security/rbac.dart';
import '../widgets/app_colors.dart';
import '../widgets/bp_theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_section.dart';
import 'widgets/finance_summary_cards.dart';
import 'widgets/finance_filter_section.dart';
import 'widgets/finance_transaction_table.dart';
import 'widgets/finance_charts.dart';
import 'widgets/finance_add_transaction_dialog.dart';
import '../utils/pdf_export_helper.dart';

/// Page principale de Finance & Comptabilité
class PharmacyFinancePage extends StatelessWidget {
  const PharmacyFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FinancePageContent();
  }
}

class FinancePageContent extends StatefulWidget {
  const FinancePageContent({super.key});

  @override
  State<FinancePageContent> createState() => _FinancePageContentState();
}

class _FinancePageContentState extends State<FinancePageContent> {
  late List<FinanceTransactionModel> _filteredTransactions;

  // Filtres
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  String? _selectedPaymentMethod;
  String? _selectedEmployee;
  double? _minAmount;
  double? _maxAmount;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  // Tri
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredTransactions = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadTransactions();
    });
  }

  Future<void> _reloadTransactions() async {
    await context.read<FinanceProvider>().loadTransactions(forceRefresh: true);
    if (!mounted) return;
    _applyFilters();
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => FinanceAddTransactionDialog(
        onTransactionAdded: (transaction) {
          final financeProvider = Provider.of<FinanceProvider>(
            context,
            listen: false,
          );
          financeProvider.addTransaction(transaction);
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    setState(() {
      _filteredTransactions = financeProvider.getFilteredTransactions(
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
        paymentMethod: _selectedPaymentMethod,
        employeeName: _selectedEmployee,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _currentPage = 0; // Reset pagination
    });
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
      _selectedPaymentMethod = null;
      _selectedEmployee = null;
      _minAmount = null;
      _maxAmount = null;
      _searchQuery = '';
      _filteredTransactions = Provider.of<FinanceProvider>(
        context,
        listen: false,
      ).transactions;
      _currentPage = 0;
    });
  }

  void _sortTransactions(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _filteredTransactions.sort((a, b) {
        int result = 0;
        switch (columnIndex) {
          case 0: // Date
            result = a.dateTime.compareTo(b.dateTime);
            break;
          case 1: // Type
            result = a.type.compareTo(b.type);
            break;
          case 2: // Référence
            result = a.reference.compareTo(b.reference);
            break;
          case 3: // Source
            result = a.sourceModule.compareTo(b.sourceModule);
            break;
          case 4: // Description
            result = a.description.compareTo(b.description);
            break;
          case 5: // Montant
            result = a.amount.compareTo(b.amount);
            break;
          case 6: // Entrée/Sortie
            result = a.isIncome.toString().compareTo(b.isIncome.toString());
            break;
          case 7: // Mode paiement
            result = a.paymentMethod.compareTo(b.paymentMethod);
            break;
          case 8: // Employé
            result = a.employeeName.compareTo(b.employeeName);
            break;
        }
        return ascending ? result : -result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canViewFinance =
        user?.can(AppPermission.viewFinancialReports) ?? false;

    if (!canViewFinance) {
      return const Center(child: Text('Acces non autorise a ce module.'));
    }

    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, _) {
        // Met à jour les transactions filtrées à partir du provider et filtre uniquement les entrées
        _filteredTransactions = financeProvider
            .getFilteredTransactions(
              startDate: _startDate,
              endDate: _endDate,
              type: _selectedType,
              paymentMethod: _selectedPaymentMethod,
              employeeName: _selectedEmployee,
              minAmount: _minAmount,
              maxAmount: _maxAmount,
              searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
            )
            .where((t) => t.isIncome)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            if (isMobile) {
              return _buildMobileView(financeProvider);
            } else {
              return _buildDesktopView(financeProvider);
            }
          },
        );
      },
    );
  }

  Widget _buildMobileView(FinanceProvider financeProvider) {
    final canAddEntry =
        context.read<AuthProvider>().user?.can(AppPermission.addFinanceEntry) ??
        false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête mobile (standardisé)
          AppCard(
            title: 'Finance & Comptabilité',
            child: Row(
              children: [
                if (canAddEntry)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddTransactionDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: financeProvider.isLoading
                      ? null
                      : () => _reloadTransactions(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cartes résumé mobile
          FinanceSummaryCards(startDate: _startDate, endDate: _endDate),
          const SizedBox(height: 16),

          // Filtres mobile
          FinanceFilterSection(
            selectedType: _selectedType,
            selectedPaymentMethod: _selectedPaymentMethod,
            searchQuery: _searchQuery,
            onSearchChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
            onTypeChanged: (value) {
              setState(() {
                _selectedType = value;
                _applyFilters();
              });
            },
            onPaymentMethodChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
                _applyFilters();
              });
            },
            onResetFilters: _resetFilters,
          ),
          const SizedBox(height: 16),

          // Transactions mobile (ListView)
          _buildMobileTransactionsList(),
          const SizedBox(height: 16),

          // Graphiques mobile
          FinanceCharts(startDate: _startDate, endDate: _endDate),
        ],
      ),
    );
  }

  Widget _buildDesktopView(FinanceProvider financeProvider) {
    final canAddEntry =
        context.read<AuthProvider>().user?.can(AppPermission.addFinanceEntry) ??
        false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête desktop
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1100) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Use AppSection for a consistent title + subtitle
                    AppSection(
                      title: 'Finance & Comptabilité',
                      child: Text(
                        'Suivi des revenus, dépenses et trésorerie',
                        style: TextStyle(
                          color: BpColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search and Filter
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: TextField(
                              onChanged: (value) {
                                _searchQuery = value;
                                _applyFilters();
                              },
                              style: const TextStyle(
                                color: BpColors.textPrimary,
                              ),
                              decoration: BpInputTheme.light(
                                label: 'Recherche',
                                hint: 'Recherche...',
                                prefixIcon: Icons.search,
                                showLabel: false,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 220,
                          height: 54,
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            isExpanded: true,
                            dropdownColor: BpColors.surface,
                            decoration: BpInputTheme.light(
                              label: 'Type',
                              hint: 'Type',
                              showLabel: false,
                            ),
                            style: const TextStyle(
                              color: BpColors.textPrimary,
                              fontSize: 14,
                            ),
                            items: ['Vente', 'Retour', 'Approvisionnement']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Actions grouped inside an AppCard for consistency
                    AppCard(
                      child: Row(
                        children: [
                          if (canAddEntry)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddTransactionDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une transaction'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: financeProvider.isLoading
                                ? null
                                : () => _reloadTransactions(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return AppCard(
                // Desktop wide header wrapped in AppCard for consistent spacing
                child: Row(
                  children: [
                    // Left: Title
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Finance & Comptabilité',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: BpColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Suivi des revenus, dépenses et trésorerie',
                            style: TextStyle(
                              color: BpColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Middle: Search and Filter
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: SizedBox(
                                height: 54,
                                child: TextField(
                                  onChanged: (value) {
                                    _searchQuery = value;
                                    _applyFilters();
                                  },
                                  style: const TextStyle(
                                    color: BpColors.textPrimary,
                                  ),
                                  decoration: BpInputTheme.light(
                                    label: 'Recherche',
                                    hint: 'Recherche globale...',
                                    prefixIcon: Icons.search,
                                    showLabel: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            height: 54,
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              isExpanded: true,
                              dropdownColor: BpColors.surface,
                              decoration: BpInputTheme.light(
                                label: 'Type',
                                hint: 'Type',
                                showLabel: false,
                              ),
                              style: const TextStyle(
                                color: BpColors.textPrimary,
                                fontSize: 14,
                              ),
                              items: ['Vente', 'Retour', 'Approvisionnement']
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Actions
                    // Keep the existing actions inside the AppCard child
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            tooltip: 'Exporter en PDF',
                            onPressed: () async {
                              if (_filteredTransactions.isEmpty) {
                                AppScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Aucune donnée à exporter.'),
                                  ),
                                );
                                return;
                              }
                              AppScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Génération du PDF en cours...',
                                  ),
                                ),
                              );
                              try {
                                await PdfExportHelper.exportFinances(
                                  _filteredTransactions,
                                  'Rapport des Finances',
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  AppScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Erreur lors de la génération du PDF.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Rafraîchir',
                            onPressed: financeProvider.isLoading
                                ? null
                                : () => _reloadTransactions(),
                          ),
                          if (canAddEntry) ...[
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showAddTransactionDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          FinanceSummaryCards(startDate: _startDate, endDate: _endDate),
          const SizedBox(height: 24),
          // Advanced filters are shown on mobile; avoid duplicating on desktop
          const SizedBox(height: 24),
          AppCard(
            title: 'Transactions',
            child: FinanceTransactionTable(
              transactions: _filteredTransactions,
              currentPage: _currentPage,
              rowsPerPage: _rowsPerPage,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: _sortTransactions,
              onPreviousPage: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
              onNextPage:
                  (_currentPage + 1) * _rowsPerPage <
                      _filteredTransactions.length
                  ? () => setState(() => _currentPage++)
                  : null,
              onViewDetails: _showTransactionDetails,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            title: 'Graphiques',
            child: FinanceCharts(startDate: _startDate, endDate: _endDate),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune transaction trouvée'),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isIncome
                  ? kPrimaryGreen
                  : kDangerRed,
              child: Icon(
                transaction.isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${transaction.type} • ${transaction.sourceModule}'),
                Text(
                  '${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}',
                  style: TextStyle(color: BpColors.textSecondary),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.amount} fcfa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? kPrimaryGreen : kDangerRed,
                  ),
                ),
                Text(
                  transaction.paymentMethod,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () => _showTransactionDetails(transaction),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(FinanceTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la transaction'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', transaction.type),
              _buildDetailRow('Référence', transaction.reference),
              _buildDetailRow('Source', transaction.sourceModule),
              _buildDetailRow('Description', transaction.description),
              _buildDetailRow('Montant', '${transaction.amount} fcfa'),
              _buildDetailRow(
                'Type',
                transaction.isIncome ? 'Revenu' : 'Dépense',
              ),
              _buildDetailRow('Mode de paiement', transaction.paymentMethod),
              _buildDetailRow('Employé', transaction.employeeName),
              _buildDetailRow(
                'Date',
                '${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year} ${transaction.dateTime.hour}:${transaction.dateTime.minute}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
