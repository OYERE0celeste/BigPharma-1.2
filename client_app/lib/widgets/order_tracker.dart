import 'package:flutter/material.dart';

import 'bp_theme.dart';

class OrderTracker extends StatelessWidget {
  final String status;

  const OrderTracker({super.key, required this.status});

  int _getStatusStep() {
    switch (status) {
      case 'en_attente':
        return 0;
      case 'en_preparation':
        return 1;
      case 'pret_pour_recuperation':
        return 2;
      case 'validee':
        return 3;
      case 'annulee':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getStatusStep();
    if (currentStep == -1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BpColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: BpColors.error),
            SizedBox(width: 8),
            Text(
              'Commande annulée',
              style: TextStyle(
                color: BpColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {'label': 'En attente', 'icon': Icons.access_time},
      {'label': 'Préparation', 'icon': Icons.inventory_2_outlined},
      {'label': 'Prêt', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Livré', 'icon': Icons.check_circle_outline},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isActive = index <= currentStep;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  // Dot and Line
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : BpColors.borderStrong,
                        ),
                        child: Icon(
                          steps[index]['icon'] as IconData,
                          size: 16,
                          color: isActive
                              ? Colors.white
                              : BpColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 54,
                        child: Text(
                          steps[index]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : BpColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: index < currentStep
                            ? Theme.of(context).primaryColor
                            : BpColors.borderStrong,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
