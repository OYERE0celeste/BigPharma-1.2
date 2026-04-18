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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDashboard(orderProvider),
            const SizedBox(height: 24),
            _buildFiltersAndSearch(),
            const SizedBox(height: 16),
            Expanded(
              child: orderProvider.isLoading && orderProvider.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildOrdersList(orderProvider),
            ),
            _buildPagination(orderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestion des commandes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              'Suivi en temps réel du cycle de commande client.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => _loadOrders(page: 1),
          icon: const Icon(Icons.refresh),
          label: const Text('Rafraîchir'),
        ),
      ],
    );
  }

  Widget _buildDashboard(OrderProvider provider) {
    return Row(
      children: [
        _buildStatCard(
          'En attente',
          '${provider.stats['en_attente'] ?? 0}',
          Colors.orange,
          Icons.timer_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'En préparation',
          '${provider.stats['en_preparation'] ?? 0}',
          Colors.deepPurple,
          Icons.inventory_2_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'En livraison',
          '${provider.stats['en_livraison'] ?? 0}',
          Colors.teal,
          Icons.local_shipping_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Livrées',
          '${provider.stats['livree'] ?? 0}',
          Colors.green,
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191D23),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher par numéro ou client...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _loadOrders(page: 1);
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
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
          Wrap(
            spacing: 4,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Détails',
                onPressed: () => _viewDetails(order),
              ),
              ...order.availableNextStatuses.map(
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
      case OrderStatus.validee:
        return Icons.check_circle_outline;
      case OrderStatus.enPreparation:
        return Icons.inventory_2_outlined;
      case OrderStatus.enLivraison:
        return Icons.local_shipping_outlined;
      case OrderStatus.livree:
        return Icons.task_alt;
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
