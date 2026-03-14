import 'package:epharma/models/product_model.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final StockStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case StockStatus.available:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Available';
        icon = Icons.check_circle;
        break;
      case StockStatus.lowStock:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Low Stock';
        icon = Icons.warning;
        break;
      case StockStatus.outOfStock:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Out of Stock';
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}