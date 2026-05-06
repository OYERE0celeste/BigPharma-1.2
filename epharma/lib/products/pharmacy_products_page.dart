import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _filter = 'Tous les produits';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    try {
      await context.read<ProductProvider>().loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des produits : $e')),
        );
      }
    }
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
      //appBar: AppBar(
      //title: const Text('Gestion des produits'),
      //backgroundColor: Colors.white,
      //foregroundColor: Colors.black87,
      // elevation: 1,
      // ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final products = provider.products;

          // Apply local filters to the provider's products
          final filtered = products.where((p) {
            final q = _search.toLowerCase();
            if (q.isNotEmpty &&
                !(p.name.toLowerCase().contains(q) ||
                    p.category.toLowerCase().contains(q))) {
              return false;
            }
            if (_filter == 'Stock faible' &&
                p.availableStock > p.lowStockThreshold) {
              return false;
            }
            if (_filter == 'Rupture de stock' && p.availableStock > 0) {
              return false;
            }
            if (_filter == 'Expirés' && p.expirationStatus != 'EXPIRÉ') {
              return false;
            }
            if (_filter == 'Bientôt expirés' &&
                p.expirationStatus != 'BIENTÔT EXPIRÉ') {
              return false;
            }
            if (_filter == 'Ordonnance requise' && !p.prescriptionRequired) {
              return false;
            }
            return true;
          }).toList();

          // Sort
          filtered.sort((a, b) {
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

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                if (provider.isLoading && products.isEmpty)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: ProductTable(
                      products: filtered,
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
                          try {
                            await provider.updateProduct(updated);
                            await provider.loadProducts();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur mise à jour produit : $e',
                                  ),
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
                            title: const Text('Confirmer la suppression'),
                            content: Text('Supprimer ${p.name} ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          try {
                            await provider.deleteProduct(p.id);
                            await provider.loadProducts();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur suppression produit : $e',
                                  ),
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'GESTION DES PRODUITS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérez les médicaments, le stock et les lots pharmaceutiques',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search and Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        hintText: 'Rechercher...',
                        hintStyle: const TextStyle(fontSize: 14),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filter,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Tous les produits',
                            child: Text('Tous'),
                          ),
                          DropdownMenuItem(
                            value: 'Stock faible',
                            child: Text('Faible'),
                          ),
                          DropdownMenuItem(
                            value: 'Expirés',
                            child: Text('Expirés'),
                          ),
                          DropdownMenuItem(
                            value: 'Bientôt expirés',
                            child: Text('Bientôt'),
                          ),
                          DropdownMenuItem(
                            value: 'Ordonnance requise',
                            child: Text('Ord.'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _filter = v ?? 'Tous les produits'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un produit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadProducts,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualiser',
                    color: Colors.black54,
                  ),
                ],
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Left: Title and Subtitle
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'GESTION DES PRODUITS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gérez les médicaments, le stock et les lots pharmaceutiques',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Middle: Search and Filter
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 20),
                            hintText: 'Rechercher par nom ou catégorie',
                            hintStyle: const TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filter,
                          icon: const Icon(Icons.arrow_drop_down),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Tous les produits',
                              child: Text('Tous les produits'),
                            ),
                            DropdownMenuItem(
                              value: 'Stock faible',
                              child: Text('Stock faible'),
                            ),
                            DropdownMenuItem(
                              value: 'Expirés',
                              child: Text('Expirés'),
                            ),
                            DropdownMenuItem(
                              value: 'Bientôt expirés',
                              child: Text('Bientôt expirés'),
                            ),
                            DropdownMenuItem(
                              value: 'Ordonnance requise',
                              child: Text('Ordonnance requise'),
                            ),
                          ],
                          onChanged: (v) => setState(
                              () => _filter = v ?? 'Tous les produits'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Actions
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualiser les produits',
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _openAddDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
