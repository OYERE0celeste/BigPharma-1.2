import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _loadDetails();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final authProvider = context.read<AuthProvider>();
    final data = await context.read<OrderProvider>().fetchOrderDetails(
      widget.orderId,
      authProvider.token!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _order = data?['order'] as OrderModel?;
      _timeline = (data?['timeline'] as List<OrderTimelineEntry>?) ?? [];
      _isLoading = false;
    });
  }

  String _formatMoney(double amount) => '${amount.toStringAsFixed(0)} FCFA';

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: Text('Commande non trouvée.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande ${_order!.orderNumber}'),
        actions: [
          if (_order!.availableNextStatuses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: _showStatusUpdateDialog,
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
        _buildInfoCard(
          'Statut',
          _order!.status.label,
          Icons.info_outline,
          color: _order!.status.color,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          'Total',
          _formatMoney(_order!.totalPrice),
          Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          'Ordonnance',
          _order!.prescriptionRequired ? 'Requise' : 'Non requise',
          Icons.description_outlined,
          color: _order!.prescriptionRequired ? Colors.orange : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produits commandés',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity} x ${_formatMoney(item.price)}',
                ),
                trailing: Text(
                  _formatMoney(item.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'TOTAL : ${_formatMoney(_order!.totalPrice)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._timeline.map(_buildTimelineItem),
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
              decoration: BoxDecoration(
                color: entry.status.color,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 40, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.status.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${entry.userName} - ${_formatTimestamp(entry.timestamp)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (entry.note != null && entry.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    entry.note!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog() {
    final noteController = TextEditingController();
    OrderStatus? selectedStatus = _order!.availableNextStatuses.isNotEmpty
        ? _order!.availableNextStatuses.first
        : null;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mettre à jour le statut'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<OrderStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Nouveau statut'),
                items: _order!.availableNextStatuses
                    .map(
                      (status) => DropdownMenuItem<OrderStatus>(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedStatus = value,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedStatus == null) {
                  return;
                }

                final auth = context.read<AuthProvider>();
                final provider = context.read<OrderProvider>();
                final success = await provider.updateOrderStatus(
                  _order!.id,
                  selectedStatus!.apiValue,
                  noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                  auth.token!,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Statut mis à jour.'
                          : (provider.errorMessage ??
                                'Échec de la mise à jour.'),
                    ),
                  ),
                );

                if (success) {
                  _loadDetails();
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }
}
