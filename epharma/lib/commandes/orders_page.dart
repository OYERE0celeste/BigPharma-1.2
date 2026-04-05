import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order_model.dart';
import 'order_details_page.dart';
import 'order_creation_dialog.dart';
import 'order_export.dart';

class PharmacyOrdersPage extends StatefulWidget {
  const PharmacyOrdersPage({super.key});

  @override
  State<PharmacyOrdersPage> createState() => _PharmacyOrdersPageState();
}

class _PharmacyOrdersPageState extends State<PharmacyOrdersPage> {
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders({int page = 1}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<OrderProvider>(context, listen: false).fetchOrders(
      authProvider: authProvider,
      page: page,
      status: _selectedStatus,
      search: _searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
              child: orderProvider.isLoading
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
              'Gestion des Commandes',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            Text(
              'Gérez et suivez les commandes de vos clients en temps réel.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _showExportDialog(),
              icon: const Icon(Icons.download),
              label: const Text('Exporter'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openCreationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle commande'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboard(OrderProvider provider) {
    // Note: Dashboard statistics could be refined by adding a specific endpoint in real use.
    // For now, we display them based on current context if needed or just static.
    return Row(
      children: [
        _buildStatCard('En attente', '3', Colors.orange, Icons.timer_outlined),
        const SizedBox(width: 16),
        _buildStatCard('Validées', '8', Colors.blue, Icons.check_circle_outline),
        const SizedBox(width: 16),
        _buildStatCard('Livrées', '45', Colors.green, Icons.local_shipping_outlined),
        const SizedBox(width: 16),
        _buildStatCard('Annulées', '2', Colors.red, Icons.cancel_outlined),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191D23))),
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
              hintText: 'Rechercher par numéro de commande...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
              _loadOrders();
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text('Filtrer par statut'),
              value: _selectedStatus,
              items: OrderStatus.values.map((s) => DropdownMenuItem(value: s.name, child: Text(s.label))).toList()
                ..insert(0, const DropdownMenuItem(value: null, child: Text("Tous les statuts"))),
              onChanged: (val) {
                setState(() => _selectedStatus = val);
                _loadOrders();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(OrderProvider provider) {
    if (provider.orders.isEmpty) {
      return const Center(child: Text('Aucune commande trouvée.'));
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
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            columns: const [
              DataColumn(label: Text('N° Commande')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('Actions')),
            ],
            rows: provider.orders.map((order) => _buildOrderRow(order)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(OrderModel order) {
    return DataRow(cells: [
      DataCell(Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(order.clientName)),
      DataCell(Text(order.formattedDate)),
      DataCell(Text('${order.total.toStringAsFixed(2)} €')),
      DataCell(_buildStatusBadge(order.status)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _viewDetails(order),
            tooltip: 'Détails',
          ),
          if (order.status == OrderStatus.pending)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editOrder(order),
              tooltip: 'Modifier',
            ),
        ],
      )),
    ]);
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.validated:
        color = Colors.blue;
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildPagination(OrderProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: provider.currentPage > 1 ? () => _loadOrders(page: provider.currentPage - 1) : null,
          ),
          Text('Page ${provider.currentPage} sur ${provider.totalPages}'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: provider.currentPage < provider.totalPages ? () => _loadOrders(page: provider.currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  void _viewDetails(OrderModel order) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderDetailsPage(orderId: order.id)));
  }

  void _openCreationDialog() {
    showDialog(context: context, builder: (context) => const OrderCreationDialog()).then((_) => _loadOrders());
  }

  void _showExportDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: OrderExportWidget(token: auth.token ?? ''),
      ),
    );
  }

  void _editOrder(OrderModel order) {
    // Implementation for edit could be similar to creation
  }
}
