import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';

typedef SupplierActionCallback = void Function(Supplier supplier);

class SupplierTable extends StatelessWidget {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? error;
  final SupplierActionCallback onOrder;
  final SupplierActionCallback onInfo;
  final SupplierActionCallback onEdit;
  final SupplierActionCallback onDelete;

  const SupplierTable({
    super.key,
    required this.suppliers,
    required this.isLoading,
    required this.error,
    required this.onOrder,
    required this.onInfo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur: $error'));
    }
    if (suppliers.isEmpty) {
      return const Center(child: Text('Aucun fournisseur trouvé.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Contact')),
          DataColumn(label: Text('Téléphone')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Adresse')),
          DataColumn(label: Text('Ville')),
          DataColumn(label: Text('Date ajout')),
          DataColumn(label: Text('Statut')),
          DataColumn(label: Text('Actions')),
        ],
        rows: suppliers
            .map(
              (supplier) => DataRow(
                cells: [
                  DataCell(Text(supplier.name)),
                  DataCell(Text(supplier.contactName)),
                  DataCell(Text(supplier.phone)),
                  DataCell(Text(supplier.email)),
                  DataCell(Text(supplier.address)),
                  DataCell(Text(supplier.city)),
                  DataCell(
                    Text(
                      '${supplier.createdAt.day}/${supplier.createdAt.month}/${supplier.createdAt.year}',
                    ),
                  ),
                  DataCell(Chip(label: Text(supplier.statusDisplay))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.green,
                          ),
                          onPressed: () => onOrder(supplier),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info, color: Colors.blue),
                          onPressed: () => onInfo(supplier),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => onEdit(supplier),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(supplier),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
