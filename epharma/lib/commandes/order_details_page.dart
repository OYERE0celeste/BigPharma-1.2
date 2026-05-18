import 'dart:async';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
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
    final canSubstitute = [_order!.status == OrderStatus.enAttente || _order!.status == OrderStatus.enPreparation];

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              final isPendingOrPrep = _order!.status == OrderStatus.enAttente ||
                  _order!.status == OrderStatus.enPreparation;
              final isAllowed = item.allowSubstitution;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (item.wasSubstituted) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Text(
                                    'Substitué',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${_formatMoney(item.price)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (item.wasSubstituted && item.originalPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Prix d\'origine : ${_formatMoney(item.originalPrice!)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          if (!item.wasSubstituted && isAllowed && isPendingOrPrep)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Substitution autorisée par le client',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatMoney(item.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (!item.wasSubstituted && isAllowed && isPendingOrPrep) ...[
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () => _showSubstitutionDialog(index, item),
                            icon: const Icon(Icons.swap_horiz, size: 14),
                            label: const Text('Remplacer'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(color: Colors.blue[300]!),
                              foregroundColor: Colors.blue[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
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
                AppScaffoldMessenger.of(context).showSnackBar(
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

  void _showSubstitutionDialog(int index, OrderItem item) {
    showDialog<void>(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> substitutes = [];
        bool loadingSubstitutes = true;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (loadingSubstitutes) {
              final auth = context.read<AuthProvider>();
              context
                  .read<OrderProvider>()
                  .fetchProductSubstitutes(item.productId, auth.token!)
                  .then((value) {
                if (context.mounted) {
                  setStateDialog(() {
                    substitutes = value;
                    loadingSubstitutes = false;
                  });
                }
              }).catchError((e) {
                if (context.mounted) {
                  setStateDialog(() {
                    dialogError = 'Erreur de chargement: $e';
                    loadingSubstitutes = false;
                  });
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Text('Substituer l\'article'),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Article original à remplacer :',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Quantité commandée : ${item.quantity}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatMoney(item.subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alternatives de substitution (Génériques) :',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (loadingSubstitutes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (dialogError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else if (substitutes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(Icons.info_outline, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              const Text(
                                'Aucun produit générique/substitut trouvé pour cet article.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: substitutes.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final sub = substitutes[index];
                            final subId = sub['_id'] as String;
                            final subName = sub['name'] as String;
                            final subPrice = (sub['sellingPrice'] as num).toDouble();
                            final subStock = (sub['availableStock'] as num).toInt();
                            final isStockSufficient = subStock >= item.quantity;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              'Prix: ${_formatMoney(subPrice)}',
                                              style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isStockSufficient
                                                    ? Colors.green[50]
                                                    : Colors.red[50],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Stock: $subStock dispo',
                                                style: TextStyle(
                                                  color: isStockSufficient
                                                      ? Colors.green[800]
                                                      : Colors.red[800],
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: !isStockSufficient
                                        ? null
                                        : () async {
                                            final auth = context.read<AuthProvider>();
                                            final provider = context.read<OrderProvider>();
                                            final success = await provider.substituteOrderItem(
                                              orderId: _order!.id,
                                              itemIndex: index,
                                              substituteProductId: subId,
                                              token: auth.token!,
                                            );

                                            if (!context.mounted) return;
                                            Navigator.pop(context);

                                            AppScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Article substitué avec succès par $subName.'
                                                      : (provider.errorMessage ??
                                                          'Échec de la substitution.'),
                                                ),
                                              ),
                                            );

                                            if (success) {
                                              _loadDetails();
                                            }
                                          },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text('Choisir'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
            );
          },
        );
      },
    );
  }
}

