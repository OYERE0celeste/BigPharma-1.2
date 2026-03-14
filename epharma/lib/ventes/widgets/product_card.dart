import 'package:epharma/models/product_model.dart';
import 'package:flutter/material.dart';
import '../../products/widgets/status_badge.dart';
import '../../widgets/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
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
      elevation: isSelected ? 8 : 2,
      color: isSelected ? kSoftBlue : Colors.white,
      child: InkWell(
        onTap: availableStock > 0 ? onAddToCart : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (product.prescriptionRequired)
                    Tooltip(
                      message: 'Prescription Required',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kDangerRed, width: 1),
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kDangerRed,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.category,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              StatusBadge(status: status),
              const SizedBox(height: 6),
              Text(
                'Stock: $availableStock',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                  if (availableStock > 0)
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: Colors.grey[600],
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