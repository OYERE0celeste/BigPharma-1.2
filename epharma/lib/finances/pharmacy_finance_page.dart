import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/finance_model.dart';
import '../providers/finance_provider.dart';
import '../services/finance_service.dart';
import '../main_layout.dart';

/// Page principale de Finance & Comptabilité
class PharmacyFinancePage extends StatelessWidget {
  const PharmacyFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      pageTitle: 'Finances', 
      child: const FinancePageContent());
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
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    financeProvider.initialize();
    _filteredTransactions = financeProvider.transactions;
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSummary(),
            const SizedBox(height: 24),
            _buildAdvancedFilters(),
            const SizedBox(height: 24),
            _buildFinancialFlowsTable(),
            const SizedBox(height: 24),
            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Finance & Comptabilité'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        // Sélecteur de période
        DropdownButton<String>(
          value: 'Aujourd\'hui',
          dropdownColor: Theme.of(context).primaryColor,
          style: const TextStyle(color: Colors.white),
          items: ['Aujourd\'hui', 'Semaine', 'Mois', 'Personnalisé']
              .map(
                (period) =>
                    DropdownMenuItem(value: period, child: Text(period)),
              )
              .toList(),
          onChanged: (value) {
            // TODO: Implémenter la logique de changement de période
          },
        ),
        const SizedBox(width: 16),
        // Bouton Export PDF
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Export PDF',
          onPressed: () {
            // TODO: Implémenter export PDF
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Export PDF - Fonctionnalité à implémenter'),
              ),
            );
          },
        ),
        // Bouton Export Excel
        IconButton(
          icon: const Icon(Icons.table_chart),
          tooltip: 'Export Excel',
          onPressed: () {
            // TODO: Implémenter export Excel
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Export Excel - Fonctionnalité à implémenter'),
              ),
            );
          },
        ),
        // Bouton Rafraîchir
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Rafraîchir',
          onPressed: () {
            final financeProvider = Provider.of<FinanceProvider>(
              context,
              listen: false,
            );
            setState(() {
              _filteredTransactions = financeProvider.transactions;
              _applyFilters();
            });
          },
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final totalRevenue = financeProvider.getTotalRevenue(
      startDate: _startDate,
      endDate: _endDate,
    );
    final totalExpenses = financeProvider.getTotalExpenses(
      startDate: _startDate,
      endDate: _endDate,
    );
    final netProfit = financeProvider.getNetProfit(
      startDate: _startDate,
      endDate: _endDate,
    );
    final paymentBreakdown = financeProvider.getPaymentMethodBreakdown(
      startDate: _startDate,
      endDate: _endDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résumé Financier',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryCard(
              '💰 Chiffre d\'affaires total',
              FinanceService.formatAmount(totalRevenue),
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '📉 Total des dépenses',
              FinanceService.formatAmount(totalExpenses),
              Colors.red,
              Icons.trending_down,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '📈 Profit net',
              FinanceService.formatAmount(netProfit),
              netProfit >= 0 ? Colors.green : Colors.red,
              netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              '💳 Répartition paiements',
              '${paymentBreakdown.length} méthodes',
              Colors.blue,
              Icons.payment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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

  Widget _buildAdvancedFilters() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres Avancés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche globale',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  hint: const Text('Type de transaction'),
                  value: _selectedType,
                  items:
                      [
                            'Vente',
                            'Paiement fournisseur',
                            'Dépense',
                            'Retour',
                            'Approvisionnement',
                          ]
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
                const SizedBox(width: 16),
                DropdownButton<String>(
                  hint: const Text('Mode de paiement'),
                  value: _selectedPaymentMethod,
                  items: ['Espèces', 'Carte', 'Virement']
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialFlowsTable() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    final displayedTransactions = _filteredTransactions.sublist(
      startIndex,
      endIndex > _filteredTransactions.length
          ? _filteredTransactions.length
          : endIndex,
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
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(
                  label: const Text('Date'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Type'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Référence'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Source'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Description'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Montant'),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Entrée/Sortie'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Mode paiement'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Employé'),
                  onSort: (columnIndex, ascending) =>
                      _sortTransactions(columnIndex, ascending),
                ),
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
                          // TODO: Afficher détails de la transaction
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Détails de ${transaction.reference}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_filteredTransactions.length} transactions'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text('${_currentPage + 1}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: endIndex < _filteredTransactions.length
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final chartData = financeProvider.getRevenueVsExpensesData(
      startDate: _startDate,
      endDate: _endDate,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyse Graphique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < chartData.length) {
                            final date =
                                chartData[value.toInt()]['date'] as DateTime;
                            return Text(DateFormat('dd/MM').format(date));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(FinanceService.formatAmount(value));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['revenue'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['expenses'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 3,
                      child: ColoredBox(color: Colors.green),
                    ),
                    SizedBox(width: 8),
                    Text('Revenus'),
                  ],
                ),
                SizedBox(width: 32),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 3,
                      child: ColoredBox(color: Colors.red),
                    ),
                    SizedBox(width: 8),
                    Text('Dépenses'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
