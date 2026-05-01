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
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? kAccentBlue : Colors.grey.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? kSoftBlue : Colors.white,
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
                      ),
                    ),
                  ),
                  if (product.prescriptionRequired)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: kDangerRed, width: 0.5),
                      ),
                      child: const Text(
                        'Rx',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: kDangerRed,
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
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: status),
                  Text(
                    'Stock: $availableStock',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
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
                    color: availableStock > 0 ? kAccentBlue : Colors.grey[300],
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