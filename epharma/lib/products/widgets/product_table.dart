import 'package:epharma/products/pharmacy_products_page.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/bp_theme.dart';
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
  final ValueChanged<Product>? onEdit;
  final ValueChanged<Product>? onDelete;
  final ValueChanged<List<Product>>? onBulkDelete;

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
    this.onBulkDelete,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  final Set<String> _selectedIds = {};

  int get pageCount => (widget.products.length / widget.rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final start = widget.currentPage * widget.rowsPerPage;
    final items = widget.products.skip(start).take(widget.rowsPerPage).toList();

    return Card(
      elevation: 2,
      color: BpColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: BpColors.borderStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_selectedIds.isNotEmpty && widget.onBulkDelete != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Text(
                      '${_selectedIds.length} produit(s) sélectionné(s)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        final selectedProducts = widget.products
                            .where((p) => _selectedIds.contains(p.id))
                            .toList();
                        widget.onBulkDelete!(selectedProducts);
                        setState(() => _selectedIds.clear());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer la sélection'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: BpColors.borderStrong),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: _buildDataTable(items),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Lignes par page :', style: TextStyle(color: BpColors.textSecondary)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: widget.rowsPerPage,
                      dropdownColor: BpColors.surface,
                      style: const TextStyle(color: BpColors.textPrimary),
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
                      icon: const Icon(Icons.chevron_left, color: BpColors.textPrimary),
                    ),
                    Text('${widget.currentPage + 1} / $pageCount', style: const TextStyle(color: BpColors.textPrimary)),
                    IconButton(
                      onPressed: widget.currentPage < pageCount - 1
                          ? () => widget.onPageChanged(widget.currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right, color: BpColors.textPrimary),
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
      onSelectAll: (isSelected) {
        setState(() {
          if (isSelected == true) {
            _selectedIds.addAll(items.map((p) => p.id));
          } else {
            _selectedIds.clear();
          }
        });
      },
      sortColumnIndex: _colIndex(widget.sortColumn),
      sortAscending: widget.sortAscending,
      headingRowColor: WidgetStateProperty.all(BpColors.surface),
      columnSpacing: 24,
      horizontalMargin: 24,
      dataRowMinHeight: 56,
      dataRowMaxHeight: 64,
      headingRowHeight: 56,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: BpColors.textPrimary,
      ),
      columns: [
        DataColumn(label: _colHeader('Nom du produit', 'name')),
        DataColumn(label: _colHeader('Catégorie', 'category')),
        DataColumn(label: _colHeader('Prix d\'achat', 'purchase')),
        DataColumn(label: _colHeader('Prix de vente', 'selling')),
        DataColumn(label: _colHeader('Stock total', 'stock')),
        const DataColumn(label: Text('Expiration la plus proche')),
        const DataColumn(label: Text('Nombre de lots')),

        const DataColumn(label: Text('Statut')),
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

        final isSelected = _selectedIds.contains(p.id);

        return DataRow(
          selected: isSelected,
          onSelectChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedIds.add(p.id);
              } else {
                _selectedIds.remove(p.id);
              }
            });
          },
          color: WidgetStateProperty.resolveWith<Color?>((states) => rowColor),
          cells: [
            DataCell(
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: BpColors.textPrimary)),
            ),
            DataCell(Text(p.category, style: const TextStyle(color: BpColors.textSecondary))),
            DataCell(Text('${p.purchasePrice.toStringAsFixed(0)} FCFA', style: const TextStyle(color: BpColors.textSecondary))),
            DataCell(Text('${p.sellingPrice.toStringAsFixed(0)} FCFA', style: const TextStyle(color: BpColors.textSecondary))),
            DataCell(Text('${p.totalStock}', style: const TextStyle(color: BpColors.textSecondary))),
            DataCell(Text(nearest != null ? formatDate(nearest) : '-', style: const TextStyle(color: BpColors.textSecondary))),
            DataCell(Text('${p.lots.length}', style: const TextStyle(color: BpColors.textSecondary))),

            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(status: status),
                  if (p.expirationStatus == 'EXPIRÉ') ...[
                    const SizedBox(width: 4),
                    _buildExpirationBadge('Expiré', Colors.red),
                  ] else if (p.expirationStatus == 'BIENTÔT EXPIRÉ') ...[
                    const SizedBox(width: 4),
                    _buildExpirationBadge('Bientôt', Colors.orange),
                  ],
                ],
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () => widget.onView(p),
                    icon: const Icon(Icons.visibility, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onEdit == null
                          ? null
                          : () => widget.onEdit!(p),
                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onDelete == null
                          ? null
                          : () => widget.onDelete!(p),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
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
          Text(label, style: const TextStyle(color: BpColors.textPrimary)),
          if (widget.sortColumn == col)
            Icon(
              widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: BpColors.textPrimary,
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
    if (p.totalStock == 0) return StockStatus.outOfStock;
    if (p.totalStock <= p.lowStockThreshold) return StockStatus.lowStock;
    return StockStatus.available;
  }

  Widget _buildExpirationBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
