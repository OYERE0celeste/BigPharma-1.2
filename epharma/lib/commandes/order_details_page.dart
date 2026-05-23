import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_invoice_model.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_invoice_service.dart';
import '../services/receipt_export_service.dart';
import '../widgets/app_notification.dart';
import '../widgets/bp_theme.dart';
import '../widgets/detail_widgets.dart';
import '../widgets/receipt_ticket.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  static const Duration _autoRefreshInterval = Duration(seconds: 30);

  OrderModel? _order;
  OrderInvoiceModel? _invoice;
  List<OrderTimelineEntry> _timeline = [];
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _invoiceErrorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _refreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
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
    final token = authProvider.token;
    if (token == null) {
      return;
    }

    final details = await context.read<OrderProvider>().fetchOrderDetails(
      widget.orderId,
      token,
    );

    OrderInvoiceModel? invoice;
    String? invoiceError;
    try {
      invoice = await OrderInvoiceService.fetchOrderInvoice(widget.orderId);
    } catch (error) {
      invoiceError = error.toString();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _order = details?['order'] as OrderModel?;
      _timeline = (details?['timeline'] as List<OrderTimelineEntry>?) ?? [];
      _invoice = invoice;
      _invoiceErrorMessage = invoiceError;
      _isLoading = false;
    });
  }

  String _formatMoney(double amount) => '${amount.toStringAsFixed(0)} FCFA';

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} a $hour:$minute';
  }

  Future<void> _downloadInvoice() async {
    final order = _order;
    if (order == null || _isDownloading) {
      return;
    }

    final receipt = _invoice != null
        ? ReceiptTicketFactory.fromOrderInvoice(
            _invoice!,
            operatorName: order.userName,
          )
        : ReceiptTicketFactory.fromOrder(order);

    setState(() => _isDownloading = true);
    try {
      await ReceiptExportService.downloadReceipt(
        receipt,
        filename: '${receipt.invoiceNumber}.pdf',
      );
      if (!mounted) {
        return;
      }
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture prete pour telechargement.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de telecharger la facture: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: BpColors.accent)),
      );
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: Text('Commande non trouvee.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande ${_order!.orderNumber}'),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            onPressed: _isDownloading ? null : _downloadInvoice,
            tooltip: 'Telecharger la facture',
          ),
          if (_order!.availableNextStatuses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: _showStatusUpdateDialog,
              tooltip: 'Mettre a jour le statut',
            ),
        ],
      ),
      body: Container(
        color: BpColors.scaffoldSecondary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoicePreviewSection(),
              const SizedBox(height: 24),
              _buildOrderInfoCards(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1100) {
                    return Column(
                      children: [
                        _buildItemsList(),
                        const SizedBox(height: 24),
                        _buildTimeline(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildItemsList()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildTimeline()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicePreviewSection() {
    final receipt = _invoice != null
        ? ReceiptTicketFactory.fromOrderInvoice(
            _invoice!,
            operatorName: _order!.userName,
          )
        : ReceiptTicketFactory.fromOrder(_order!);

    final previewLabel = _invoice != null
        ? 'Facture disponible'
        : 'Apercu facture / commande';
    final helperText = _invoice != null
        ? 'Le ticket reprend le format caisse pour consultation ou telechargement.'
        : 'La facture definitive n est pas encore synchronisee. Un apercu de commande est affiche.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      helperText,
                      style: const TextStyle(color: BpColors.textSecondary),
                    ),
                    if (_invoiceErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _invoiceErrorMessage!,
                        style: const TextStyle(color: BpColors.warning),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isDownloading ? null : _downloadInvoice,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Telecharger'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(child: ReceiptTicket(data: receipt)),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          DetailMetricCard(
            icon: Icons.person_outline,
            label: 'Client',
            value: _order!.clientName,
            tone: BpColors.surface.withOpacity(0.65),
          ),
          DetailMetricCard(
            icon: Icons.info_outline,
            label: 'Statut',
            value: _order!.status.label,
            tone: _order!.status.color.withOpacity(0.16),
          ),
          DetailMetricCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total',
            value: _formatMoney(_order!.totalPrice),
            tone: BpColors.accent,
          ),
        ];

        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
            const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? BpColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BpColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: BpColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produits commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BpColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: BpColors.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) =>
                const Divider(color: BpColors.border),
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              final isPendingOrPrep =
                  _order!.status == OrderStatus.enAttente ||
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: BpColors.textPrimary,
                                ),
                              ),
                              if (item.wasSubstituted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BpColors.warning.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: BpColors.warning.withOpacity(0.45),
                                    ),
                                  ),
                                  child: const Text(
                                    'Substitue',
                                    style: TextStyle(
                                      color: BpColors.warning,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${_formatMoney(item.price)}',
                            style: const TextStyle(
                              color: BpColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          if (item.wasSubstituted && item.originalPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Prix d origine : ${_formatMoney(item.originalPrice!)}',
                                style: const TextStyle(
                                  color: BpColors.textHint,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          if (!item.wasSubstituted &&
                              isAllowed &&
                              isPendingOrPrep)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.swap_horiz,
                                    size: 16,
                                    color: BpColors.accent,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Substitution autorisee par le client',
                                      style: TextStyle(
                                        color: BpColors.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                            color: BpColors.textPrimary,
                          ),
                        ),
                        if (!item.wasSubstituted &&
                            isAllowed &&
                            isPendingOrPrep) ...[
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showSubstitutionDialog(index, item),
                            icon: const Icon(Icons.swap_horiz, size: 14),
                            label: const Text('Remplacer'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          const Divider(color: BpColors.border),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'TOTAL : ${_formatMoney(_order!.totalPrice)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BpColors.accent,
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
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BpColors.textPrimary,
            ),
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
            Container(width: 2, height: 40, color: BpColors.borderStrong),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.status.label,
                style: const TextStyle(
                  color: BpColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${entry.userName} - ${_formatTimestamp(entry.timestamp)}',
                style: const TextStyle(
                  color: BpColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (entry.note != null && entry.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    entry.note!,
                    style: const TextStyle(
                      color: BpColors.textSecondary,
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
          title: const Text('Mettre a jour le statut'),
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
                  labelText: 'Note optionnelle',
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
                          ? 'Statut mis a jour.'
                          : (provider.errorMessage ??
                                'Echec de la mise a jour.'),
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

  void _showSubstitutionDialog(int orderItemIndex, OrderItem item) {
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
                  })
                  .catchError((e) {
                    if (context.mounted) {
                      setStateDialog(() {
                        dialogError = 'Erreur de chargement: $e';
                        loadingSubstitutes = false;
                      });
                    }
                  });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.swap_horiz, color: BpColors.accent),
                  SizedBox(width: 8),
                  Text('Substituer l article'),
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
                        color: BpColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BpColors.borderStrong),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Article original a remplacer :',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: BpColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: BpColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Quantite commandee : ${item.quantity}',
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
                              color: BpColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alternatives de substitution :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (loadingSubstitutes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(
                            color: BpColors.accent,
                          ),
                        ),
                      )
                    else if (dialogError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(color: BpColors.error),
                          ),
                        ),
                      )
                    else if (substitutes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: BpColors.textHint,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Aucun substitut trouve pour cet article.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: BpColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: substitutes.length,
                          separatorBuilder: (context, index) =>
                              const Divider(color: BpColors.border),
                          itemBuilder: (context, index) {
                            final sub = substitutes[index];
                            final subId = sub['_id'] as String;
                            final subName = sub['name'] as String;
                            final subPrice = (sub['sellingPrice'] as num)
                                .toDouble();
                            final subStock = (sub['availableStock'] as num)
                                .toInt();
                            final isStockSufficient = subStock >= item.quantity;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: BpColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            Text(
                                              'Prix: ${_formatMoney(subPrice)}',
                                              style: const TextStyle(
                                                color: BpColors.accent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isStockSufficient
                                                    ? BpColors.success
                                                          .withOpacity(0.12)
                                                    : BpColors.error
                                                          .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Stock: $subStock dispo',
                                                style: TextStyle(
                                                  color: isStockSufficient
                                                      ? BpColors.success
                                                      : BpColors.error,
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
                                            final auth = context
                                                .read<AuthProvider>();
                                            final provider = context
                                                .read<OrderProvider>();
                                            final success = await provider
                                                .substituteOrderItem(
                                                  orderId: _order!.id,
                                                  itemIndex: orderItemIndex,
                                                  substituteProductId: subId,
                                                  token: auth.token!,
                                                );

                                            if (!context.mounted) {
                                              return;
                                            }
                                            Navigator.pop(context);

                                            AppScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Article substitue par $subName.'
                                                      : (provider
                                                                .errorMessage ??
                                                            'Echec de la substitution.'),
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
