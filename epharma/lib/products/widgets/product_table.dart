import 'package:epharma/products/pharmacy_products_page.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'status_badge.dart';

class ProductTable extends StatefulWidget {
  final List<Product> products;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final void Function(String column) onSort;
  final String sortColumn;
  final bool sortAscending;
  final ValueChanged<Product> onView;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  const ProductTable({
    super.key,
    required this.products,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onSort,
    required this.sortColumn,
    required this.sortAscending,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  int get pageCount => (widget.products.length / widget.rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final start = widget.currentPage * widget.rowsPerPage;
    final items = widget.products.skip(start).take(widget.rowsPerPage).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(items),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Rows per page:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: widget.rowsPerPage,
                      items: const [10, 20, 50]
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text('$e')),
                          )
                          .toList(),
                      onChanged: (v) => widget.onRowsPerPageChanged(v ?? 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.currentPage > 0
                          ? () => widget.onPageChanged(widget.currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('${widget.currentPage + 1} / $pageCount'),
                    IconButton(
                      onPressed: widget.currentPage < pageCount - 1
                          ? () => widget.onPageChanged(widget.currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Product> items) {
    return DataTable(
      sortColumnIndex: _colIndex(widget.sortColumn),
      sortAscending: widget.sortAscending,
      columns: [
        DataColumn(label: _colHeader('Product Name', 'name')),
        const DataColumn(label: Text('SKU')),
        DataColumn(label: _colHeader('Category', 'category')),
        DataColumn(label: _colHeader('Purchase Price', 'purchase')),
        DataColumn(label: _colHeader('Selling Price', 'selling')),
        DataColumn(label: _colHeader('Total Stock', 'stock')),
        const DataColumn(label: Text('Nearest Expiration')),
        const DataColumn(label: Text('Lot Count')),
        const DataColumn(label: Text('Prescription')),
        const DataColumn(label: Text('Status')),
        const DataColumn(label: Text('Actions')),
      ],
      rows: items.map((p) {
        final nearest = _nearestExpiration(p);
        final status = _productStatus(p);
        
        // Coloration des lignes en fonction du statut d'expiration
        Color? rowColor;
        if (p.expirationStatus == 'EXPIRÉ') {
          rowColor = Colors.red.withOpacity(0.08);
        } else if (p.expirationStatus == 'BIENTÔT EXPIRÉ') {
          rowColor = Colors.orange.withOpacity(0.08);
        }

        return DataRow(
          onSelectChanged: (_) => widget.onView(p),
          color: WidgetStateProperty.resolveWith<Color?>((states) => rowColor),
          cells: [
            DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(p.sku)),
            DataCell(Text(p.category)),
            DataCell(Text('€${p.purchasePrice.toStringAsFixed(2)}')),
            DataCell(Text('€${p.sellingPrice.toStringAsFixed(2)}')),
            DataCell(Text('${p.totalStock}')),
            DataCell(Text(nearest != null ? formatDate(nearest) : '-')),
            DataCell(Text('${p.lots.length}')),
            DataCell(
              p.prescriptionRequired
                  ? const Icon(Icons.check_circle, color: Colors.blue, size: 18)
                  : const Icon(Icons.cancel, color: Colors.grey, size: 18),
            ),
            DataCell(StatusBadge(status: status)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () => widget.onView(p),
                    icon: const Icon(Icons.visibility, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => widget.onEdit(p),
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => widget.onDelete(p),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int? _colIndex(String col) {
    switch (col) {
      case 'name':
        return 0;
      case 'category':
        return 1;
      case 'purchase':
        return 2;
      case 'selling':
        return 3;
      case 'stock':
        return 4;
    }
    return null;
  }

  Widget _colHeader(String label, String col) {
    return InkWell(
      onTap: () => widget.onSort(col),
      child: Row(
        children: [
          Text(label),
          if (widget.sortColumn == col)
            Icon(
              widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
            ),
        ],
      ),
    );
  }

  DateTime? _nearestExpiration(Product p) {
    if (p.lots.isEmpty) return null;
    p.lots.sort((a, b) => a.expiration.compareTo(b.expiration));
    return p.lots.first.expiration;
  }

  StockStatus _productStatus(Product p) {
    if (p.lots.any((l) => l.status == LotStatus.expired)) {
      return StockStatus.outOfStock;
    }
    if (p.totalStock <= p.lowStockThreshold) return StockStatus.lowStock;
    return StockStatus.available;
  }
}