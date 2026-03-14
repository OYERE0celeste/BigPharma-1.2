import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';

class StatusChipSupplier extends StatelessWidget {
  final SupplierStatus status;
  const StatusChipSupplier({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == SupplierStatus.active
        ? Colors.green
        : status == SupplierStatus.inactive
            ? Colors.grey
            : Colors.red;
    final label = status == SupplierStatus.active
        ? 'Actif'
        : status == SupplierStatus.inactive
            ? 'Inactif'
            : 'Suspendu';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
