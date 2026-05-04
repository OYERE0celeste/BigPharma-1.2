import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'order_details_page.dart';

class PharmacyOrdersPage extends StatefulWidget {
  const PharmacyOrdersPage({super.key});

  @override
  State<PharmacyOrdersPage> createState() => _PharmacyOrdersPageState();
}

class _PharmacyOrdersPageState extends State<PharmacyOrdersPage> {
  String _searchQuery = '';
  String? _selectedStatus;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _loadOrders(page: context.read<OrderProvider>().currentPage);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadOrders({int page = 1}) {
    final authProvider = context.read<AuthProvider>();
    context.read<OrderProvider>().fetchOrders(
      authProvider: authProvider,
      page: page,
      status: _selectedStatus,
      search: _searchQuery,
    );
  }

  Future<void> _applyStatusChange(OrderModel order, OrderStatus status) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<OrderProvider>();
    final success = await provider.updateOrderStatus(
      order.id,
      status.apiValue,
      null,
      auth.token!,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Commande ${order.orderNumber} mise à jour.'
              : (provider.errorMessage ?? 'Échec de la mise à jour.'),
        ),
      ),
    );

    if (success) {
      _loadOrders(page: context.read<OrderProvider>().currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDashboard(orderProvider),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              SizedBox(
                height: 500, // Fixed height for table container or use ConstrainedBox
                child: orderProvider.isLoading && orderProvider.orders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildOrdersList(orderProvider),
              ),
              _buildPagination(orderProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  'Gestion des commandes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Suivi en temps réel du cycle de commande.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par numéro ou client...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _loadOrders(page: 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      hint: const Text('Filtrer par statut', style: TextStyle(fontSize: 14)),
                      value: _selectedStatus,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tous les statuts'),
                        ),
                        ...OrderStatus.values.map(
                          (status) => DropdownMenuItem<String?>(
                            value: status.apiValue,
                            child: Text(status.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                        _loadOrders(page: 1);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () => _loadOrders(page: 1),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rafraîchir'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(OrderProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 5;
        if (width < 600) {
          crossAxisCount = 2;
        // ignore: curly_braces_in_flow_control_structures
        } else if (width < 1000) crossAxisCount = 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: width < 600 ? 1.5 : 2.0,
          children: [
            _buildStatCard(
              'En attente',
              '${provider.stats['en_attente'] ?? 0}',
              Colors.orange,
              Icons.timer_outlined,
            ),
            _buildStatCard(
              'Préparation',
              '${provider.stats['en_preparation'] ?? 0}',
              Colors.blue,
              Icons.inventory_2_outlined,
            ),
            _buildStatCard(
              'Prêtes',
              '${provider.stats['pret_pour_recuperation'] ?? 0}',
              Colors.purple,
              Icons.shopping_bag_outlined,
            ),
            _buildStatCard(
              'Validées',
              '${provider.stats['validee'] ?? 0}',
              Colors.green,
              Icons.check_circle_outline,
            ),
            _buildStatCard(
              'Annulées',
              '${provider.stats['annulee'] ?? 0}',
              Colors.red,
              Icons.cancel_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showIcon = constraints.maxWidth > 80;
          return Row(
            children: [
              if (showIcon) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191D23),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 350,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro ou client...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _loadOrders(page: 1);
                },
              ),
            ),
            Container(
              width: isMobile ? double.infinity : 220,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Filtrer par statut'),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous les statuts'),
                    ),
                    ...OrderStatus.values.map(
                      (status) => DropdownMenuItem<String?>(
                        value: status.apiValue,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _loadOrders(page: 1);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersList(OrderProvider provider) {
    if (provider.orders.isEmpty) {
      return Center(
        child: Text(provider.errorMessage ?? 'Aucune commande trouvée.'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            columns: const [
              DataColumn(label: Text('N° Commande')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('Ordonnance')),
              DataColumn(label: Text('Actions')),
            ],
            rows: provider.orders.map(_buildOrderRow).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(OrderModel order) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            order.orderNumber,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(order.clientName)),
        DataCell(Text(order.formattedDate)),
        DataCell(Text('${order.totalPrice.toStringAsFixed(0)} FCFA')),
        DataCell(_buildStatusBadge(order.status)),
        DataCell(
          Icon(
            order.prescriptionRequired
                ? Icons.check_circle
                : Icons.remove_circle_outline,
            color: order.prescriptionRequired ? Colors.orange : Colors.grey,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Détails',
                onPressed: () => _viewDetails(order),
              ),
              const SizedBox(width: 4),
              ...order.availableNextStatuses
                  .where((s) =>
                      !(order.status == OrderStatus.validee &&
                          s == OrderStatus.annulee))
                  .map(
                (status) => IconButton(
                  icon: Icon(_actionIcon(status), color: status.color),
                  tooltip: status.label,
                  onPressed: () => _applyStatusChange(order, status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _actionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.enPreparation:
        return Icons.inventory_2_outlined;
      case OrderStatus.pretPourRecuperation:
        return Icons.shopping_bag_outlined;
      case OrderStatus.validee:
        return Icons.check_circle_outline;
      case OrderStatus.annulee:
        return Icons.cancel_outlined;
      case OrderStatus.enAttente:
        return Icons.timer_outlined;
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPagination(OrderProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: provider.currentPage > 1
                ? () => _loadOrders(page: provider.currentPage - 1)
                : null,
          ),
          Text('Page ${provider.currentPage} sur ${provider.totalPages}'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: provider.currentPage < provider.totalPages
                ? () => _loadOrders(page: provider.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  void _viewDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: order.id)),
    );
  }
}
