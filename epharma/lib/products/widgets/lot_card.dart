import 'package:epharma/products/pharmacy_products_page.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/app_colors.dart';

class LotCard extends StatelessWidget {
  final Lot lot;

  const LotCard({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (lot.status) {
      case LotStatus.expired:
        label = 'Expired';
        color = kDangerRed;
        break;
      case LotStatus.nearExpiration:
        label = 'Near Expiration';
        color = kWarningOrange;
        break;
      default:
        label = 'Valid';
        color = kPrimaryGreen;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lot: ${lot.lotNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Qty: ${lot.quantity}'),
                Text('Exp: ${formatDate(lot.expiration)}'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}