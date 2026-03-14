import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';

typedef SupplierActionCallback = void Function(Supplier supplier);

class MobileSuppliersList extends StatelessWidget {
  final List<Supplier> suppliers;
  final SupplierActionCallback onOrder;
  final SupplierActionCallback onInfo;
  final SupplierActionCallback onEdit;
  final SupplierActionCallback onDelete;

  const MobileSuppliersList({
    super.key,
    required this.suppliers,
    required this.onOrder,
    required this.onInfo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (suppliers.isEmpty) {
      return const Center(child: Text('Aucun fournisseur trouvé.'));
    }

    return ListView.builder(
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'F',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(supplier.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact: ${supplier.contactName}'),
                Text('Téléphone: ${supplier.phone}'),
                const SizedBox(height: 4),
                Chip(
                  label: Text(supplier.statusDisplay),
                  backgroundColor: supplier.status == SupplierStatus.active
                      ? Colors.green[100]
                      : Colors.grey[200],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'order') onOrder(supplier);
                if (value == 'info') onInfo(supplier);
                if (value == 'edit') onEdit(supplier);
                if (value == 'delete') onDelete(supplier);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'order', child: Text('Commande')),
                PopupMenuItem(value: 'info', child: Text('Infos')),
                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
            onTap: () => onInfo(supplier),
          ),
        );
      },
    );
  }
}
