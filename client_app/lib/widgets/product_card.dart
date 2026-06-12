import 'package:flutter/material.dart';

import '../models/product.dart';
import 'bp_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddTap;
  final VoidCallback? onDetailsTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final stockColor = _stockColor(product.stockStatus);
    final canAddToCart = !product.isOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: BpColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BpColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetailsTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: BpColors.surfaceStrong),
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: _buildProductImage(product.image, primary),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BpColors.surface.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Container
              Expanded(
                flex: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 155;
                    final ultraCompact = constraints.maxHeight < 135;

                    return Padding(
                      padding: EdgeInsets.all(compact ? 10 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 14 : 15,
                                  height: 1.15,
                                  color: BpColors.textPrimary,
                                ),
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: compact ? 2 : 4),
                              if (!ultraCompact)
                                Text(
                                  product.description,
                                  style: TextStyle(
                                    fontSize: compact ? 11 : 12,
                                    color: BpColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(height: compact ? 6 : 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 8 : 10,
                                  vertical: compact ? 4 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stockColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  product.stockStatusLabel,
                                  style: TextStyle(
                                    fontSize: compact ? 10 : 11,
                                    color: stockColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${product.sellingPrice.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: compact ? 15 : 16,
                                    color: primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: compact ? 6 : 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: canAddToCart
                                      ? primary
                                      : BpColors.textSecondary.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(
                                    compact ? 10 : 12,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: canAddToCart ? onAddTap : null,
                                  icon: Icon(
                                    Icons.add_shopping_cart,
                                    color: canAddToCart
                                        ? Colors.white
                                        : Colors.white70,
                                    size: compact ? 18 : 20,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.all(compact ? 7 : 8),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Color _stockColor(ProductStockStatus status) {
    switch (status) {
      case ProductStockStatus.inStock:
        return Colors.green;
      case ProductStockStatus.lowStock:
        return Colors.orange;
      case ProductStockStatus.outOfStock:
        return BpColors.error;
    }
  }

  Widget _buildProductImage(String image, Color primary) {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderImage(primary),
      );
    }

    return _buildPlaceholderImage(primary);
  }

  Widget _buildPlaceholderImage(Color primary) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: BpColors.surface.withOpacity(0.16),
      child: Center(
        child: Text(
          'Image indisponible',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primary.withOpacity(0.85),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
