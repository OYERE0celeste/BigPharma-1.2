import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
import '../ventes/pharmacy_sales_page.dart';
import '../clients/pharmacy_clients_page.dart';
import '../activites/pharmacy_activity_register_page.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

String formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

// Pharmacy Products Page
// - Material 3 friendly
// - Clean-ish separation with a mock ProductService
// - Reusable widgets: ProductTable, ProductDetailsPanel, LotCard, StatusBadge, ProductFormDialog

// colors are in app_colors.dart

// ----------------------------- Page -----------------------------
class PharmacyProductsPage extends StatefulWidget {
  const PharmacyProductsPage({super.key});

  @override
  State<PharmacyProductsPage> createState() => _PharmacyProductsPageState();
}

class _PharmacyProductsPageState extends State<PharmacyProductsPage> {
  String _search = '';
  String _filter = 'All products';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts();
    });
  }

  List<Product> get _filtered {
    final products = Provider.of<ProductProvider>(context).products;
    var list = products.where((p) {
      final q = _search.toLowerCase();
      if (q.isNotEmpty &&
          !(p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))) {
        return false;
      }
      if (_filter == 'Low stock' && p.availableStock > p.lowStockThreshold) {
        return false;
      }
      if (_filter == 'Out of stock' && p.availableStock > 0) {
        return false;
      }
      return true;
    }).toList();

    // Sort
    list.sort((a, b) {
      int result = 0;
      switch (_sortColumn) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'category':
          result = a.category.compareTo(b.category);
          break;
        case 'stock':
          result = a.availableStock.compareTo(b.availableStock);
          break;
        case 'price':
          result = a.sellingPrice.compareTo(b.sellingPrice);
          break;
      }
      return _sortAscending ? result : -result;
    });

    return list;
  }

  void _changeSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  void _openAddDialog() async {
    final created = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(),
    );
    if (created != null) {
      final productProvider = Provider.of<ProductProvider>(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      );
      await productProvider.addProduct(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Row(
        children: [
          // Use the shared application sidebar
          AppSidebar(
            selectedLabel: 'Stock',
            callbacks: {
              'Dashboard': () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              'Sales': () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PharmacySalesPage()),
              ),
              'Clients': () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PharmacyClientsPage()),
              ),
              'Activity': () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PharmacyActivityRegisterPage(),
                ),
              ),
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ProductTable(
                      products: _filtered,
                      rowsPerPage: _rowsPerPage,
                      currentPage: _currentPage,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                      onRowsPerPageChanged: (r) =>
                          setState(() => _rowsPerPage = r),
                      onSort: _changeSort,
                      sortColumn: _sortColumn,
                      sortAscending: _sortAscending,
                      onView: (p) => showDialog(
                        context: context,
                        builder: (_) => ProductDetailsPanel(product: p),
                      ),
                      onEdit: (p) async {
                        final updated = await showDialog<Product>(
                          context: context,
                          builder: (_) => ProductFormDialog(product: p),
                        );
                        if (updated != null) {
                          final productProvider = Provider.of<ProductProvider>(
                            // ignore: use_build_context_synchronously
                            context,
                            listen: false,
                          );
                          await productProvider.updateProduct(updated);
                        }
                      },
                      onDelete: (p) async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm delete'),
                            content: Text('Delete ${p.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          final productProvider = Provider.of<ProductProvider>(
                            // ignore: use_build_context_synchronously
                            context,
                            listen: false,
                          );
                          await productProvider.deleteProduct(p.id);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        label: const Text('Add New Product'),
        icon: const Icon(Icons.add),
        backgroundColor: kPrimaryGreen,
      ),*/
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Product Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage medicines, stock, and pharmaceutical lots',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by name or category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: _filter,
          items: const [
            DropdownMenuItem(
              value: 'All products',
              child: Text('All products'),
            ),
            DropdownMenuItem(value: 'Low stock', child: Text('Low stock')),
            DropdownMenuItem(value: 'Expired', child: Text('Expired')),
            DropdownMenuItem(
              value: 'Near expiration',
              child: Text('Near expiration'),
            ),
            DropdownMenuItem(
              value: 'Prescription required',
              child: Text('Prescription required'),
            ),
          ],
          onChanged: (v) => setState(() => _filter = v ?? 'All products'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add New Product'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
        ),
      ],
    );
  }
}

// ----------------------------- Product Table -----------------------------
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
        return DataRow(
          onSelectChanged: (_) => widget.onView(p),
          cells: [
            DataCell(Text(p.name)),
            DataCell(Text(p.category)),
            DataCell(Text('€${p.purchasePrice.toStringAsFixed(2)}')),
            DataCell(Text('€${p.sellingPrice.toStringAsFixed(2)}')),
            DataCell(Text('${p.totalStock}')),
            DataCell(Text(nearest != null ? formatDate(nearest) : '-')),
            DataCell(Text('${p.lots.length}')),
            DataCell(
              p.prescriptionRequired
                  ? const Chip(label: Text('Yes'))
                  : const Chip(label: Text('No')),
            ),
            DataCell(StatusBadge(status: status)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () => widget.onView(p),
                    icon: const Icon(Icons.visibility),
                  ),
                  IconButton(
                    onPressed: () => widget.onEdit(p),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => widget.onDelete(p),
                    icon: const Icon(Icons.delete, color: Colors.red),
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

// ----------------------------- Status Badge -----------------------------
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

// ----------------------------- Product Details Panel -----------------------------
class ProductDetailsPanel extends StatelessWidget {
  final Product product;

  const ProductDetailsPanel({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 900,
        height: 620,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _leftColumn()),
                    const SizedBox(width: 16),
                    Expanded(child: _rightColumn()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow('Name', product.name),
          _infoRow('Description', product.description),
          _infoRow('Category', product.category),
          _infoRow('Supplier', product.supplier),
          _infoRow('Barcode', product.barcode),
          _infoRow('Prescription', product.prescriptionRequired ? 'Yes' : 'No'),
          _infoRow(
            'Purchase price',
            '€${product.purchasePrice.toStringAsFixed(2)}',
          ),
          _infoRow(
            'Selling price',
            '€${product.sellingPrice.toStringAsFixed(2)}',
          ),
          _infoRow(
            'Profit margin',
            '€${product.profitMargin.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          const Text(
            'Movement history',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: const Center(child: Text('Movement history placeholder')),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock & Lots',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Total stock: ${product.totalStock}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text('Low stock threshold: ${product.lowStockThreshold}'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: product.lots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => LotCard(lot: product.lots[index]),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text('$label:')),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ----------------------------- Lot Card -----------------------------
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

// ----------------------------- Product Form Dialog -----------------------------
class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descController;
  late final TextEditingController _supplierController;
  late final TextEditingController _barcodeController;
  bool _prescription = false;
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;
  late final TextEditingController _thresholdController;
  // initial lot
  late final TextEditingController _lotNumberController;
  late final TextEditingController _lotQtyController;
  DateTime? _lotExp;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _supplierController = TextEditingController(text: p?.supplier ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _prescription = p?.prescriptionRequired ?? false;
    _purchaseController = TextEditingController(
      text: p != null ? p.purchasePrice.toString() : '0.0',
    );
    _sellingController = TextEditingController(
      text: p != null ? p.sellingPrice.toString() : '0.0',
    );
    _thresholdController = TextEditingController(
      text: p != null ? p.lowStockThreshold.toString() : '10',
    );
    _lotNumberController = TextEditingController();
    _lotQtyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _supplierController.dispose();
    _barcodeController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _thresholdController.dispose();
    _lotNumberController.dispose();
    _lotQtyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final p = Product(
      id: widget.product?.id ?? 'P${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descController.text.trim(),
      supplier: _supplierController.text.trim(),
      barcode: _barcodeController.text.trim(),
      prescriptionRequired: _prescription,
      purchasePrice: double.tryParse(_purchaseController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingController.text) ?? 0.0,
      lowStockThreshold: int.tryParse(_thresholdController.text) ?? 10,
      lots: _buildInitialLots(),
    );

    Navigator.of(context).pop(p);
  }

  List<Lot> _buildInitialLots() {
    if (_lotNumberController.text.isEmpty) return widget.product?.lots ?? [];
    final qty = int.tryParse(_lotQtyController.text) ?? 0;
    final exp = _lotExp ?? DateTime.now().add(const Duration(days: 365));
    return [
      Lot(
        lotNumber: _lotNumberController.text.trim(),
        manufacturingDate: DateTime.now(),
        expirationDate: exp,
        quantity: qty,
        quantityAvailable: qty,
        costPrice: double.tryParse(_purchaseController.text) ?? 0.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 780,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product == null ? 'Add Product' : 'Edit Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _supplierController,
                          decoration: const InputDecoration(
                            labelText: 'Supplier',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Barcode',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Prescription required'),
                    value: _prescription,
                    onChanged: (v) => setState(() => _prescription = v),
                  ),
                  const Divider(),
                  const Text(
                    'Pricing',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _purchaseController,
                          decoration: const InputDecoration(
                            labelText: 'Purchase price',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'Invalid number'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _sellingController,
                          decoration: const InputDecoration(
                            labelText: 'Selling price',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'Invalid number'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profit margin: €${(_sellingController.text.isEmpty || _purchaseController.text.isEmpty)
                        ? '0.00'
                        : (double.tryParse(_sellingController.text) == null || double.tryParse(_purchaseController.text) == null)
                        ? '0.00'
                        : (double.parse(_sellingController.text) - double.parse(_purchaseController.text)).toStringAsFixed(2)}',
                  ),
                  const Divider(),
                  const Text(
                    'Stock configuration',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Low stock threshold',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null)
                        ? 'Invalid number'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Initial lot (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lotNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Lot number',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lotQtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _lotExp == null
                            ? 'No expiration selected'
                            : 'Exp: ${formatDate(_lotExp!)}',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (d != null) setState(() => _lotExp = d);
                        },
                        child: const Text('Select Expiration'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// End of file
