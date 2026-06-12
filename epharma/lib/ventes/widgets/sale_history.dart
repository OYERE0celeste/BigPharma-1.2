import 'package:epharma/models/sale_model.dart';
import 'package:epharma/models/order_model.dart';
import 'package:epharma/widgets/bp_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaleHistoryTable extends StatelessWidget {
  final List<Sale> sales;
  final List<OrderModel> orders;
  final bool isLoadingOrders;
  final String? ordersErrorMessage;
  final VoidCallback? onRefreshOrders;
  final ValueChanged<Sale>? onOpenSale;
  final ValueChanged<Sale>? onDownloadSale;
  final ValueChanged<OrderModel>? onOpenOrder;
  final ValueChanged<OrderModel>? onDownloadOrder;

  const SaleHistoryTable({
    super.key,
    required this.sales,
    this.orders = const [],
    this.isLoadingOrders = false,
    this.ordersErrorMessage,
    this.onRefreshOrders,
    this.onOpenSale,
    this.onDownloadSale,
    this.onOpenOrder,
    this.onDownloadOrder,
  });

  String _formatPaymentMethod(String value) {
    switch (value.trim().toLowerCase()) {
      case 'cash':
        return 'Especes';
      case 'card':
        return 'Carte';
      case 'mobilemoney':
      case 'mobile_money':
      case 'mobile money':
        return 'Mobile Money';
      case 'transfer':
        return 'Virement';
      case 'check':
        return 'Cheque';
      default:
        return value.isEmpty ? 'Non defini' : value;
    }
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: BpColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: BpColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCounterCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: BpColors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: BpColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInvoiceCard(OrderModel order) {
    final invoiceLabel = (order.invoiceNumber ?? '').trim().isEmpty
        ? 'Pas encore de facture'
        : order.invoiceNumber!.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.cardBg,
        borderRadius: BorderRadius.circular(18),
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
                      order.orderNumber,
                      style: TextStyle(
                        color: BpColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: TextStyle(color: BpColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: BpColors.primaryLight.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.totalPrice.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: BpColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Facture: $invoiceLabel',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            'Client: ${order.clientName}',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            'Statut: ${order.status.label}',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          if (onOpenOrder != null || onDownloadOrder != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onOpenOrder != null)
                  TextButton.icon(
                    onPressed: () => onOpenOrder!(order),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Voir la commande'),
                  ),
                if (onDownloadOrder != null)
                  OutlinedButton.icon(
                    onPressed: () => onDownloadOrder!(order),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Telecharger'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.cardBg,
        borderRadius: BorderRadius.circular(18),
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
                      sale.invoiceNumber,
                      style: TextStyle(
                        color: BpColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(sale.dateTime),
                      style: TextStyle(color: BpColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: BpColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sale.totalAmount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: BpColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Paiement: ${_formatPaymentMethod(sale.paymentMethod)}',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            'Pharmacien: ${sale.pharmacist}',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            'Articles: ${sale.items.length}',
            style: TextStyle(color: BpColors.textSecondary),
          ),
          if (onOpenSale != null || onDownloadSale != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onOpenSale != null)
                  TextButton.icon(
                    onPressed: () => onOpenSale!(sale),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Voir la facture'),
                  ),
                if (onDownloadSale != null)
                  OutlinedButton.icon(
                    onPressed: () => onDownloadSale!(sale),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Telecharger'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedSales = List<Sale>.from(sales)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final sortedOrders = List<OrderModel>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final ordersWithInvoice = sortedOrders
        .where((order) => (order.invoiceNumber ?? '').trim().isNotEmpty)
        .length;

    final hasOrdersError =
        ordersErrorMessage != null && ordersErrorMessage!.trim().isNotEmpty;

    if (sortedSales.isEmpty &&
        sortedOrders.isEmpty &&
        !isLoadingOrders &&
        !hasOrdersError) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: BpColors.surfaceStrong,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BpColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: BpColors.textHint,
              ),
              SizedBox(height: 12),
              Text(
                'Aucun historique a afficher',
                style: TextStyle(
                  color: BpColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: _buildCounterCard(
                'Factures de vente',
                '${sortedSales.length}',
              ),
            ),
            SizedBox(
              width: 220,
              child: _buildCounterCard(
                'Commandes suivies',
                '${sortedOrders.length}',
              ),
            ),
            SizedBox(
              width: 220,
              child: _buildCounterCard(
                'Commandes facturees',
                '$ordersWithInvoice',
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildSectionTitle(
          'Historique des factures de vente',
          'Chaque vente enregistree avec sa facture.',
        ),
        SizedBox(height: 12),
        if (sortedSales.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Aucune vente disponible.',
              style: TextStyle(color: BpColors.textSecondary),
            ),
          )
        else
          ...sortedSales.map((sale) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSaleCard(sale),
            );
          }),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(
                'Historique des factures par commande',
                'Chaque commande avec son numero de commande et sa facture.',
              ),
            ),
            if (onRefreshOrders != null)
              TextButton.icon(
                onPressed: onRefreshOrders,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Rafraichir'),
              ),
          ],
        ),
        SizedBox(height: 12),
        if (isLoadingOrders)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: BpColors.accent),
                  SizedBox(height: 12),
                  Text(
                    'Chargement des factures de commande...',
                    style: TextStyle(color: BpColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (hasOrdersError)
          Text(
            ordersErrorMessage!,
            style: TextStyle(color: BpColors.error),
          )
        else if (sortedOrders.isEmpty)
          Text(
            'Aucune commande disponible.',
            style: TextStyle(color: BpColors.textSecondary),
          )
        else
          ...sortedOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOrderInvoiceCard(order),
            ),
          ),
      ],
    );
  }
}
