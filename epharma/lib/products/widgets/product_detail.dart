import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../widgets/bp_theme.dart';
import 'lot_card.dart';

class ProductDetailsPanel extends StatelessWidget {
  final Product product;

  const ProductDetailsPanel({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final stockColor = _stockColor(product.stockStatus);
    final expirationColor = _expirationColor(product.expirationStatus);
    final nearestLot = product.nearestExpirationLot;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1040,
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 720),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BpColors.surfaceStrong, BpColors.cardBg],
          ),
          border: Border.all(color: BpColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(28, 24, 18, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BpColors.accent.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: BpColors.border),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(product.name, style: BpTextStyles.heading2),
                              _Pill(
                                icon: Icons.category_rounded,
                                label: product.category,
                                foreground: BpColors.accent,
                                background: BpColors.accent.withOpacity(0.12),
                              ),
                              _Pill(
                                icon: Icons.inventory_2_rounded,
                                label: _stockLabel(product.stockStatus),
                                foreground: stockColor,
                                background: stockColor.withOpacity(0.12),
                              ),
                              _Pill(
                                icon: Icons.event_rounded,
                                label: product.expirationStatus,
                                foreground: expirationColor,
                                background: expirationColor.withOpacity(0.12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description.trim().isEmpty
                                ? 'Fiche produit sans description detaillee pour le moment.'
                                : product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BpTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Fermer',
                      style: IconButton.styleFrom(
                        backgroundColor: BpColors.surface.withOpacity(0.65),
                        foregroundColor: BpColors.textPrimary,
                        side: const BorderSide(color: BpColors.border),
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 900;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: isCompact
                          ? Column(
                              children: [
                                _buildOverview(nearestLot),
                                const SizedBox(height: 18),
                                _buildStockArea(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 11,
                                  child: _buildOverview(nearestLot),
                                ),
                                const SizedBox(width: 18),
                                Expanded(flex: 9, child: _buildStockArea()),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(Lot? nearestLot) {
    return Column(
      children: [
        _SectionCard(
          title: 'Informations du produit',
          subtitle:
              'Les informations essentielles de l article en un coup d oeil.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DetailTile(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Code-barres',
                      value: product.barcode.trim().isEmpty
                          ? 'Non renseigne'
                          : product.barcode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailTile(
                      icon: Icons.sell_rounded,
                      label: 'Categorie',
                      value: product.category,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BpColors.surface.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
                  border: Border.all(color: BpColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: BpTextStyles.label),
                    const SizedBox(height: 8),
                    Text(
                      product.description.trim().isEmpty
                          ? 'Aucune description detaillee pour ce produit.'
                          : product.description,
                      style: BpTextStyles.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Prix achat',
                      value: '${product.purchasePrice.toStringAsFixed(0)} FCFA',
                      icon: Icons.shopping_bag_rounded,
                      tone: BpColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Prix vente',
                      value: '${product.sellingPrice.toStringAsFixed(0)} FCFA',
                      icon: Icons.point_of_sale_rounded,
                      tone: BpColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Marge',
                      value: '${product.profitMargin.toStringAsFixed(0)} %',
                      icon: Icons.trending_up_rounded,
                      tone: BpColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Historique des mouvements',
          subtitle:
              'Zone reservee aux entrees, sorties et ajustements de stock.',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: BpColors.surface.withOpacity(0.55),
              borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
              border: Border.all(color: BpColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BpColors.accent.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: BpColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Historique a connecter',
                  style: BpTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cette section est prete pour accueillir les mouvements de stock du produit dans un format plus lisible.',
                  style: BpTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                if (nearestLot != null) ...[
                  const SizedBox(height: 18),
                  _InlineInfo(
                    icon: Icons.schedule_rounded,
                    label: 'Prochaine echeance',
                    value:
                        'Lot ${nearestLot.lotNumber} le ${_formatDate(nearestLot.expirationDate)}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockArea() {
    return _SectionCard(
      title: 'Stock & lots',
      subtitle:
          'Vision claire du stock actuel, des alertes et des lots disponibles.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Stock total',
                  value: '${product.totalStock}',
                  icon: Icons.inventory_rounded,
                  tone: _stockColor(product.stockStatus),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Seuil bas',
                  value: '${product.lowStockThreshold}',
                  icon: Icons.notifications_active_rounded,
                  tone: BpColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Nombre de lots',
                  value: '${product.lots.length}',
                  icon: Icons.layers_rounded,
                  tone: BpColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Expiration',
                  value: product.expirationStatus,
                  icon: Icons.event_busy_rounded,
                  tone: _expirationColor(product.expirationStatus),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (product.lots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BpColors.surface.withOpacity(0.55),
                borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
                border: Border.all(color: BpColors.border),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 34,
                    color: BpColors.textHint,
                  ),
                  SizedBox(height: 10),
                  Text('Aucun lot enregistre', style: BpTextStyles.heading3),
                  SizedBox(height: 6),
                  Text(
                    'Ajoutez un lot pour suivre la disponibilite et les dates d expiration.',
                    style: BpTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: product.lots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    LotCard(lot: product.lots[index]),
              ),
            ),
        ],
      ),
    );
  }

  Color _stockColor(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return BpColors.success;
      case StockStatus.lowStock:
        return BpColors.warning;
      case StockStatus.outOfStock:
        return BpColors.error;
    }
  }

  Color _expirationColor(String value) {
    switch (value) {
      case 'EXPIRÉ':
      case 'EXPIRÃ‰':
        return BpColors.error;
      case 'BIENTÔT EXPIRÉ':
      case 'BIENTÃ”T EXPIRÃ‰':
        return BpColors.warning;
      default:
        return BpColors.success;
    }
  }

  String _stockLabel(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return 'Disponible';
      case StockStatus.lowStock:
        return 'Stock faible';
      case StockStatus.outOfStock:
        return 'Rupture';
    }
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BpColors.cardHighlight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        border: Border.all(color: BpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BpTextStyles.heading3),
          const SizedBox(height: 4),
          Text(subtitle, style: BpTextStyles.caption),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BpTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: BpColors.textPrimary,
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

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: BpColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: BpColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BpTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: BpColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InlineInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong.withOpacity(0.55),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: BpColors.accent, size: 18),
          const SizedBox(width: 10),
          Text('$label : ', style: BpTextStyles.label),
          Expanded(child: Text(value, style: BpTextStyles.bodyBold)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  const _Pill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
