import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../widgets/bp_theme.dart';

class ScanResultCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEditProduct;
  final bool showActions;

  const ScanResultCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onViewDetails,
    this.onEditProduct,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final expirationColor = _getExpirationColor(product.expirationStatus);
    final stockColor = _getStockColor(product.stockStatus);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF6FFF8), const Color(0xFFEAF8EE)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7D8BF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produit trouve',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF183125),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Badge(
                            icon: Icons.qr_code_2_rounded,
                            label: product.barcode,
                            color: Colors.green,
                          ),
                          _Badge(
                            icon: Icons.category_rounded,
                            label: product.category,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.sell_rounded,
                    label: 'Prix de vente',
                    value: '${product.sellingPrice.toStringAsFixed(2)} DZD',
                    accentColor: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.inventory_2_rounded,
                    label: 'Stock disponible',
                    value: '${product.availableStock}',
                    accentColor: stockColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.attach_money_rounded,
                    label: 'Prix achat',
                    value: '${product.purchasePrice.toStringAsFixed(2)} DZD',
                    accentColor: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.layers_rounded,
                    label: 'Nombre de lots',
                    value: '${product.lots.length}',
                    accentColor: Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
            if (product.description.trim().isNotEmpty) ...[
              SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BpColors.textPrimary.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1EFE5)),
                ),
                child: Text(
                  product.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: expirationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: expirationColor.withOpacity(0.45)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 18,
                    color: expirationColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Expiration: ${product.expirationStatus}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: expirationColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              SizedBox(height: 18),
              Row(
                children: [
                  if (onEditProduct != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditProduct,
                        icon: Icon(Icons.edit_rounded),
                        label: Text('Modifier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF183125),
                          side: const BorderSide(color: Color(0xFFB7D8BF)),
                          backgroundColor: BpColors.textPrimary.withOpacity(
                            0.72,
                          ),
                          minimumSize: Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  if (onEditProduct != null &&
                      (onViewDetails != null || onAddToCart != null))
                    SizedBox(width: 12),
                  if (onViewDetails != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewDetails,
                        icon: Icon(Icons.open_in_full_rounded),
                        label: Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF183125),
                          side: const BorderSide(color: Color(0xFFB7D8BF)),
                          backgroundColor: BpColors.textPrimary.withOpacity(
                            0.72,
                          ),
                          minimumSize: Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  if (onViewDetails != null && onAddToCart != null)
                    SizedBox(width: 12),
                  if (onAddToCart != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: Icon(Icons.shopping_cart_checkout_rounded),
                        label: Text('Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BpColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getExpirationColor(String status) {
    if (status == 'EXPIRÃ‰') {
      return const Color(0xFFDC2626);
    }
    if (status == 'BIENTÃ”T EXPIRÃ‰') {
      return const Color(0xFFEA580C);
    }
    return const Color(0xFF16A34A);
  }

  Color _getStockColor(StockStatus status) {
    switch (status) {
      case StockStatus.outOfStock:
        return const Color(0xFFDC2626);
      case StockStatus.lowStock:
        return const Color(0xFFEA580C);
      case StockStatus.available:
        return const Color(0xFF16A34A);
    }
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final MaterialColor color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BpColors.textPrimary.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EFE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183125),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
