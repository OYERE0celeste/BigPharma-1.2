import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_colors.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'widgets/product_table.dart';
import 'widgets/product_detail.dart';
import 'widgets/product_form.dart';

String formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

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
  List<Product> _products = [];

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ProductProvider>();
      provider
          .loadProducts()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _products = provider.products;
            });
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur de chargement des produits : $error'),
                ),
              );
            }
          });
    });
  }

  Future<void> _loadProducts() async {
    try {
      final provider = context.read<ProductProvider>();
      await provider.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = provider.products;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des produits : $e')),
        );
      }
    }
  }

  List<Product> get _filtered {
    var list = _products.where((p) {
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

  Future<void> _openAddDialog() async {
    final created = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(),
    );
    if (created != null) {
      try {
        await context.read<ProductProvider>().addProduct(created);
        await _loadProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur ajout produit : $e')));
        }
      }
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
      body: Padding(
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
                onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
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
                    try {
                      await context.read<ProductProvider>().updateProduct(
                        updated,
                      );
                      await _loadProducts();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur mise à jour produit : $e'),
                          ),
                        );
                      }
                    }
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
                    try {
                      await context.read<ProductProvider>().deleteProduct(p.id);
                      await _loadProducts();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur suppression produit : $e'),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
