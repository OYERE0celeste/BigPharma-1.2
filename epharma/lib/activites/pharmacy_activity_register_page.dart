import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../services/activity_service.dart';

// =====================================================================
// MAIN PAGE
// =====================================================================

class PharmacyActivityRegisterPage extends StatefulWidget {
  const PharmacyActivityRegisterPage({super.key});

  @override
  State<PharmacyActivityRegisterPage> createState() =>
      _PharmacyActivityRegisterPageState();
}

class _PharmacyActivityRegisterPageState
    extends State<PharmacyActivityRegisterPage> {
  late List<ActivityModel> _filteredTransactions;

  // Filter states
  ActivityType? _selectedActivityType;
  String? _selectedEmployee;
  PaymentMethod? _selectedPaymentMethod;
  String _searchQuery = '';
  String _periodFilter = 'today';
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );
    // Apply date range filter
    DateTime startDate;
    DateTime endDate = DateTime.now().add(const Duration(days: 1));

    switch (_periodFilter) {
      case 'today':
        startDate = DateTime.now()
            .subtract(const Duration(days: 1))
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        break;
      case 'week':
        startDate = DateTime.now().subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime.now().subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(2020, 1, 1);
    }

    var rangeFiltered = activityProvider.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    _filteredTransactions = activityProvider.filterTransactions(
      transactions: rangeFiltered,
      type: _selectedActivityType,
      employeeName: _selectedEmployee,
      paymentMethod: _selectedPaymentMethod,
      searchQuery: _searchQuery,
    );

    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedLabel: 'Activity',
            callbacks: {
              'Dashboard': () =>
                  Navigator.of(context).pushReplacementNamed('/'),
              'Stock': () =>
                  Navigator.of(context).pushReplacementNamed('/products'),
              'Sales': () =>
                  Navigator.of(context).pushReplacementNamed('/sales'),
              'Clients': () =>
                  Navigator.of(context).pushReplacementNamed('/clients'),
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const HeaderSection(),
                  const SizedBox(height: 20),

                  // Statistics Cards
                  StatisticsSection(transactions: _filteredTransactions),
                  const SizedBox(height: 20),

                  // Filters
                  FiltersSection(
                    onPeriodChanged: (period) {
                      setState(() {
                        _periodFilter = period;
                      });
                      _applyFilters();
                    },
                    onActivityTypeChanged: (type) {
                      setState(() {
                        _selectedActivityType =
                            ((type?.isEmpty ?? true) ? null : type)
                                as ActivityType?;
                      });
                      _applyFilters();
                    },
                    onEmployeeChanged: (employee) {
                      setState(() {
                        _selectedEmployee = (employee?.isEmpty ?? true)
                            ? null
                            : employee;
                      });
                      _applyFilters();
                    },
                    onPaymentMethodChanged: (method) {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                      _applyFilters();
                    },
                    onSearchChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                      _applyFilters();
                    },
                    onReset: () {
                      setState(() {
                        _selectedActivityType = null;
                        _selectedEmployee = null;
                        _selectedPaymentMethod = null;
                        _searchQuery = '';
                        _periodFilter = 'today';
                      });
                      _applyFilters();
                    },
                    transactions: Provider.of<ActivityProvider>(
                      context,
                      listen: false,
                    ).transactions,
                  ),
                  const SizedBox(height: 20),

                  // Main Table
                  TransactionsTable(
                    transactions: _filteredTransactions,
                    currentPage: _currentPage,
                    pageSize: _pageSize,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    onViewDetails: (transaction) {
                      _showTransactionDetails(transaction);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Analytics Section
                  const AnalyticsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(ActivityModel transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }
}

// =====================================================================
// HEADER SECTION
// =====================================================================

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registre des Activités',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Suivi centralisé de toutes les activités quotidiennes',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            Tooltip(
              message: 'Exporter PDF',
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export PDF - Fonctionnalité future'),
                    ),
                  );
                },
                icon: const Icon(Icons.file_download),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Exporter Excel',
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export Excel - Fonctionnalité future'),
                    ),
                  );
                },
                icon: const Icon(Icons.table_chart),
                label: const Text('Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Imprimer',
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impression - Fonctionnalité future'),
                    ),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Imprimer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Rafraîchir',
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Données rafraîchies')),
                  );
                },
                icon: const Icon(Icons.refresh),
                color: kPrimaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================================
// STATISTICS SECTION
// =====================================================================

class StatisticsSection extends StatelessWidget {
  final List<ActivityModel> transactions;

  const StatisticsSection({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ActivityService.getStatistics(transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résumé Statistiques',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StatCard(
                title: 'Total des Ventes',
                value:
                    '${(stats['totalRevenue'] ?? 0).toStringAsFixed(0)} fcfa',
                icon: Icons.trending_up,
                color: kPrimaryGreen,
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Transactions',
                value: '${stats['transactionCount'] ?? 0}',
                icon: Icons.receipt,
                color: kAccentBlue,
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Total Entrées',
                value: '${(stats['totalIncome'] ?? 0).toStringAsFixed(0)} fcfa',
                icon: Icons.arrow_upward,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Total Sorties',
                value:
                    '${(stats['totalExpenses'] ?? 0).toStringAsFixed(0)} fcfa',
                icon: Icons.arrow_downward,
                color: kDangerRed,
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Bénéfice Estimé',
                value:
                    '${(stats['estimatedProfit'] ?? 0).toStringAsFixed(0)} fcfa',
                icon: Icons.trending_up,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Produits Vendus',
                value: '${stats['totalProductsSold'] ?? 0}',
                icon: Icons.inventory_2,
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// FILTERS SECTION
// =====================================================================

class FiltersSection extends StatefulWidget {
  final Function(String) onPeriodChanged;
  final Function(String?) onActivityTypeChanged;
  final Function(String?) onEmployeeChanged;
  final Function(PaymentMethod?) onPaymentMethodChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onReset;
  final List<ActivityModel> transactions;

  const FiltersSection({
    required this.onPeriodChanged,
    required this.onActivityTypeChanged,
    required this.onEmployeeChanged,
    required this.onPaymentMethodChanged,
    required this.onSearchChanged,
    required this.onReset,
    required this.transactions,
    super.key,
  });

  @override
  State<FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<FiltersSection> {
  late TextEditingController _searchController;
  String _selectedPeriod = 'today';
  String? _selectedActivityType;
  String? _selectedEmployee;
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ActivityService.getUniqueEmployees(widget.transactions);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres Avancés',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPeriod = 'today';
                    _selectedActivityType = null;
                    _selectedEmployee = null;
                    _selectedPaymentMethod = null;
                    _searchController.clear();
                  });
                  widget.onReset();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Recherche globale...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    widget.onSearchChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownMenu<String>(
                  initialSelection: _selectedPeriod,
                  label: const Text('Période'),
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      widget.onPeriodChanged(value);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'today', label: "Aujourd'hui"),
                    DropdownMenuEntry(value: 'week', label: 'Cette semaine'),
                    DropdownMenuEntry(value: 'month', label: 'Ce mois'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownMenu<String>(
                  initialSelection: _selectedActivityType,
                  label: const Text('Type Activité'),
                  onSelected: (value) {
                    setState(() {
                      _selectedActivityType = value;
                    });
                    widget.onActivityTypeChanged(value);
                  },
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'Tous'),
                    ...ActivityType.values.map(
                      (type) => DropdownMenuEntry(
                        value: type.name,
                        label: _getActivityLabel(type),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownMenu<String>(
                  initialSelection: _selectedEmployee,
                  label: const Text('Employé'),
                  onSelected: (value) {
                    setState(() {
                      _selectedEmployee = value;
                    });
                    widget.onEmployeeChanged(value);
                  },
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'Tous'),
                    ...employees.map(
                      (emp) => DropdownMenuEntry(value: emp, label: emp),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownMenu<PaymentMethod>(
                  initialSelection: _selectedPaymentMethod,
                  label: const Text('Paiement'),
                  onSelected: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                    widget.onPaymentMethodChanged(value);
                  },
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<PaymentMethod>(
                      value: PaymentMethod.other,
                      label: 'Tous',
                    ),
                    ...PaymentMethod.values.map(
                      (method) => DropdownMenuEntry(
                        value: method,
                        label: _getPaymentMethodLabel(method),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActivityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return 'Vente';
      case ActivityType.return_:
        return 'Retour';
      case ActivityType.restocking:
        return 'Approvisionnement';
      case ActivityType.supplierPayment:
        return 'Paiement Fournisseur';
      case ActivityType.stockAdjustment:
        return 'Ajustement Stock';
      case ActivityType.cancellation:
        return 'Annulation';
    }
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.card:
        return 'Carte';
      case PaymentMethod.check:
        return 'Chèque';
      case PaymentMethod.transfer:
        return 'Virement';
      case PaymentMethod.other:
        return 'Autre';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      // TODO: Handle this case.
      // throw UnimplementedError();
    }
  }
}

// =====================================================================
// TRANSACTIONS TABLE
// =====================================================================

class TransactionsTable extends StatelessWidget {
  final List<ActivityModel> transactions;
  final int currentPage;
  final int pageSize;
  final Function(int) onPageChanged;
  final Function(ActivityModel) onViewDetails;

  const TransactionsTable({
    required this.transactions,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onViewDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (transactions.length / pageSize).ceil().clamp(1, 1000);
    final start = currentPage * pageSize;
    final end = start + pageSize;
    final paginatedTransactions = transactions.sublist(
      start,
      end > transactions.length ? transactions.length : end,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date & Heure')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Référence')),
              DataColumn(label: Text('Client/Fournisseur')),
              DataColumn(label: Text('Produit')),
              DataColumn(label: Text('Quantité')),
              DataColumn(label: Text('Montant')),
              DataColumn(label: Text('Paiement')),
              DataColumn(label: Text('Employé')),
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('')),
            ],
            rows: paginatedTransactions.map((transaction) {
              return DataRow(
                cells: [
                  DataCell(Text(_formatDateTime(transaction.dateTime))),
                  DataCell(_buildActivityBadge(transaction.type)),
                  DataCell(Text(transaction.reference)),
                  DataCell(Text(transaction.clientOrSupplierName)),
                  DataCell(Text(transaction.productName)),
                  DataCell(Text('${transaction.quantity}')),
                  DataCell(
                    Text(
                      '€${transaction.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.totalAmount >= 0
                            ? kPrimaryGreen
                            : kDangerRed,
                      ),
                    ),
                  ),
                  DataCell(Text(transaction.paymentMethodLabel)),
                  DataCell(Text(transaction.employeeName)),
                  DataCell(_buildStatusBadge(transaction.status)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      onPressed: () => onViewDetails(transaction),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Affichage ${start + 1} à ${end > transactions.length ? transactions.length : end} sur ${transactions.length} transactions',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 0
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  if (index < 5 ||
                      (index >= currentPage - 2 && index <= currentPage + 2) ||
                      index >= totalPages - 2) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ElevatedButton(
                        onPressed: () => onPageChanged(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage == index
                              ? kPrimaryGreen
                              : Colors.grey[300],
                          foregroundColor: currentPage == index
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        child: Text('${index + 1}'),
                      ),
                    );
                  } else if (index == 5 || index == totalPages - 3) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('...'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages - 1
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityBadge(ActivityType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getActivityColor(type).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getActivityColor(type)),
      ),
      child: Text(
        _getActivityLabel(type),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getActivityColor(type),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return kPrimaryGreen;
      case ActivityType.return_:
        return kAccentBlue;
      case ActivityType.restocking:
        return const Color(0xFF7B1FA2);
      case ActivityType.supplierPayment:
        return kDangerRed;
      case ActivityType.stockAdjustment:
        return const Color(0xFF0097A7);
      case ActivityType.cancellation:
        return kWarningOrange;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return kPrimaryGreen;
      case TransactionStatus.pending:
        return kWarningOrange;
      case TransactionStatus.cancelled:
        return kDangerRed;
      case TransactionStatus.onHold:
        return kAccentBlue;
    }
  }

  String _getActivityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return 'Vente';
      case ActivityType.return_:
        return 'Retour';
      case ActivityType.restocking:
        return 'Approv.';
      case ActivityType.supplierPayment:
        return 'Paiement';
      case ActivityType.stockAdjustment:
        return 'Ajust.';
      case ActivityType.cancellation:
        return 'Annul.';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Complétée';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.cancelled:
        return 'Annulée';
      case TransactionStatus.onHold:
        return 'Suspens';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (txDate == today) {
      dateStr = 'Aujourd\'hui';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      dateStr = 'Hier';
    } else {
      dateStr = '${txDate.day}/${txDate.month}/${txDate.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}

// =====================================================================
// TRANSACTION DETAILS DIALOG
// =====================================================================

class TransactionDetailsDialog extends StatelessWidget {
  final ActivityModel transaction;

  const TransactionDetailsDialog({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: transaction.typeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Détails Transaction - ${transaction.reference}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSection('Informations Générales', [
                      _buildDetailRow('Référence', transaction.reference),
                      _buildDetailRow(
                        'Date & Heure',
                        _formatDateTime(transaction.dateTime),
                      ),
                      _buildDetailRow('Type', transaction.typeLabel),
                      _buildDetailRow('Statut', transaction.statusLabel),
                    ]),
                    const SizedBox(height: 16),

                    // Party Information
                    _buildSection('Tiers', [
                      _buildDetailRow('Nom', transaction.clientOrSupplierName),
                      _buildDetailRow('Employé', transaction.employeeName),
                    ]),
                    const SizedBox(height: 16),

                    // Items
                    if (transaction.listOfItems.isNotEmpty) ...[
                      _buildSection('Articles', []),
                      const SizedBox(height: 8),
                      ..._buildItemsList(),
                      const SizedBox(height: 16),
                    ],

                    // Financial Information
                    _buildSection('Informations Financières', [
                      _buildDetailRow(
                        'Montant HT',
                        '€${(transaction.totalAmount - transaction.taxAmount).abs().toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Taxes',
                        '€${transaction.taxAmount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Total',
                        '€${transaction.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      _buildDetailRow(
                        'Mode Paiement',
                        transaction.paymentMethodLabel,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Notes
                    if (transaction.notes.isNotEmpty) ...[
                      _buildSection('Notes', [
                        _buildDetailRow('Remarques', transaction.notes),
                      ]),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impression du reçu - Fonctionnalité future',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimer Reçu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 14 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsList() {
    return transaction.listOfItems.map((item) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qté: ${item.quantity} × €${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '€${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item.totalPrice >= 0 ? kPrimaryGreen : kDangerRed,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// =====================================================================
// ANALYTICS SECTION
// =====================================================================

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple : récupérer les transactions
    final transactions = Provider.of<ActivityProvider>(context).transactions;

    // Exemple : calculer ventes par jour
    final List<SalesByDay> salesByDay = ActivityService.getSalesByDay(
      transactions,
    );

    // ✅ Sécuriser les calculs
    double avgSales = salesByDay.isNotEmpty
        ? salesByDay.map((e) => e.amount).reduce((a, b) => a + b) /
              salesByDay.length
        : 0;

    if (avgSales.isNaN || avgSales.isInfinite) {
      avgSales = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analyse & Graphiques',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Exemple : carte avec graphique simple
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ventes par jours',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      salesByDay.isEmpty
                          ? const Text("Pas de données disponibles")
                          : SizedBox(height: 200, child: _buildSimpleChart()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Exemple : autre carte
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Répartition par type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChartBar('Ventes', 0, kPrimaryGreen),
                          _buildChartBar('Retours', 0, kAccentBlue),
                          _buildChartBar('Approv.', 0, const Color(0xFF7B1FA2)),
                          _buildChartBar('Autres', 0, kWarningOrange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Exemple de barre de graphique
  Widget _buildChartBar(String label, double value, Color color) {
    // ✅ Sécuriser la largeur
    final safeValue = (value.isNaN || value.isInfinite) ? 0 : value;

    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Container(
            height: 12,
            width: value.toDouble(), // valeur sécurisée
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(safeValue.toString()),
      ],
    );
  }

  Widget _buildSimpleChart() {
    final data = [0, 0, 0, 0, 0, 0, 0];
    final maxValue = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return Column(
          children: [
            Container(
              width: 20,
              height: (data[index] / maxValue * 100),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ['L', 'M', 'M', 'J', 'V', 'S', 'D'][index],
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        );
      }),
    );
  }
}
