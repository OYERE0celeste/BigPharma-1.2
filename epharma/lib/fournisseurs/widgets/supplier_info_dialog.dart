import 'package:flutter/material.dart';
import '../../widgets/app_colors.dart';
import '../../models/supplier_model.dart';

class SupplierInfoDialog extends StatelessWidget {
  final Supplier supplier;

  const SupplierInfoDialog({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: kPrimaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    supplier.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Contact', supplier.contactName),
            _buildInfoRow('Téléphone', supplier.phone),
            _buildInfoRow('Email', supplier.email),
            _buildInfoRow('Adresse', supplier.address),
            _buildInfoRow('Ville', supplier.city),
            _buildInfoRow('Pays', supplier.country),
            _buildInfoRow(
              'Date d\'ajout',
              '${supplier.createdAt.day}/${supplier.createdAt.month}/${supplier.createdAt.year}',
            ),
            _buildInfoRow('Statut', supplier.statusDisplay),
            _buildInfoRow('Total commandes', supplier.totalOrders.toString()),
            _buildInfoRow(
              'Montant total',
              '${supplier.totalAmount.toStringAsFixed(0)} FCFA',
            ),
            if (supplier.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(supplier.notes),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
