import 'package:epharma/models/sale_model.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_colors.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lot: ${cartItem.selectedLot.lotNumber}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: \$${cartItem.product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${cartItem.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: cartItem.quantity > 1 ? onDecrement : null,
                        child: Icon(
                          Icons.remove_circle,
                          size: 18,
                          color: cartItem.quantity > 1
                              ? kPrimaryGreen
                              : Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:
                            cartItem.quantity <
                                cartItem.selectedLot.quantityAvailable
                            ? onIncrement
                            : null,
                        child: Icon(
                          Icons.add_circle,
                          size: 18,
                          color:
                              cartItem.quantity <
                                  cartItem.selectedLot.quantityAvailable
                              ? kPrimaryGreen
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: kDangerRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}