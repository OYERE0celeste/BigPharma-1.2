import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order_model.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  OrderModel? _order;
  List<OrderTimelineEntry> _timeline = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = await Provider.of<OrderProvider>(context, listen: false).fetchOrderDetails(widget.orderId, authProvider.token!);
    if (data != null) {
      if (mounted) {
        setState(() {
          _order = data['order'];
          _timeline = data['timeline'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null) return const Scaffold(body: Center(child: Text("Commande non trouvée.")));

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails Commande : ${_order!.orderNumber}'),
        actions: [
          if (_order!.status != OrderStatus.cancelled && _order!.status != OrderStatus.delivered)
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => _showStatusUpdateDialog(),
              tooltip: 'Mettre à jour le statut',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfoCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildItemsList()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildTimeline()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCards() {
    return Row(
      children: [
        _buildInfoCard('Client', _order!.clientName, Icons.person_outline),
        const SizedBox(width: 16),
        _buildInfoCard('Statut Actuel', _order!.status.label, Icons.info_outline, color: _getStatusColor(_order!.status)),
        const SizedBox(width: 16),
        _buildInfoCard('Total', '${_order!.total.toStringAsFixed(2)} €', Icons.account_balance_wallet_outlined),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[600]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Articles commandés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity} x ${item.price.toStringAsFixed(2)} €'),
                trailing: Text('${item.subtotal.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text('TOTAL : ${_order!.total.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timeline / Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._timeline.map((entry) => _buildTimelineItem(entry)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(OrderTimelineEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: _getStatusColor(entry.status), shape: BoxShape.circle),
            ),
            Container(width: 2, height: 40, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.status.label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${entry.userName} - ${_formatTimestamp(entry.timestamp)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              if (entry.note != null && entry.note!.isNotEmpty)
                Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.validated: return Colors.blue;
      case OrderStatus.preparing: return Colors.purple;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _showStatusUpdateDialog() {
    String? selectedStatus;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mettre à jour le statut"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Nouveau Statut"),
                items: OrderStatus.values.map((s) => DropdownMenuItem(value: s.name, child: Text(s.label))).toList(),
                onChanged: (val) => selectedStatus = val,
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Note (optionnel)"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != null) {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final success = await Provider.of<OrderProvider>(context, listen: false)
                    .updateOrderStatus(_order!.id, selectedStatus!, noteController.text, auth.token!);
                  if (success) {
                    Navigator.pop(context);
                    _loadDetails();
                  }
                }
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }
}
