import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final StockStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case StockStatus.available:
        color = kPrimaryGreen;
        label = 'Available';
        break;
      case StockStatus.lowStock:
        color = kWarningOrange;
        label = 'Low Stock';
        break;
      case StockStatus.outOfStock:
        color = kDangerRed;
        label = 'Out of Stock';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}