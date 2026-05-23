import 'package:epharma/models/product_model.dart';
import 'package:epharma/widgets/bp_theme.dart';
import 'package:flutter/material.dart';
import '../../products/widgets/status_badge.dart';
import '../../widgets/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final bool isSelected;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = product.stockStatus;
    final availableStock = product.availableStock;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? BpColors.accent : BpColors.borderStrong,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? BpColors.cardHighlight : BpColors.cardBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: availableStock > 0 ? onAddToCart : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: BpColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: BpColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: status),
                  Text(
                    'Stock: $availableStock',
                    style: const TextStyle(
                      fontSize: 10,
                      color: BpColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${product.sellingPrice.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    availableStock > 0 ? Icons.add_circle : Icons.block,
                    size: 20,
                    color: availableStock > 0
                        ? BpColors.accent
                        : BpColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
