import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../security/rbac.dart';
import '../widgets/bp_theme.dart';
import '../widgets/common/app_ui.dart';
import '../widgets/page_stat_cards.dart';
import '../scanner/widgets/scanner_button.dart';
import '../scanner/services/scanner_context_handler.dart';
import '../scanner/services/scanner_event_bus.dart';
import 'widgets/product_table.dart';
import 'widgets/product_detail.dart';
import 'widgets/product_form.dart';

// ignore_for_file: dead_code

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
  int _rowsPerPage = 50;
  int _currentPage = 0;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Set scanner page context for products catalog page
    ScannerContextHandler.instance.setActivePage(
      ScannerActivePageContext.products,
    );
    
    // Register event handler for background keyboard scanner detection
    ScannerContextHandler.instance.registerProductsPageHandler((ProductFound event) {
      _handleScannedProduct(event.product);
    });

    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Reset scanner page context when leaving this page
    if (ScannerContextHandler.instance.activePage == ScannerActivePageContext.products) {
      ScannerContextHandler.instance.setActivePage(
        ScannerActivePageContext.other,
      );
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      await context.read<ProductProvider>().loadProducts(forceRefresh: true);
    } catch (e) {
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
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
          AppScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur ajout produit : $e')));
        }
      }
    }
  }

  void _handleScannedProduct(Product product) {
    showDialog<void>(
      context: context,
      builder: (_) => ProductDetailsPanel(product: product),
    );

    AppScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Produit scanné : ${product.name}')));
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
          final authProvider = Provider.of<AuthProvider>(context);
          final user = authProvider.user;
          final canAdd = user?.can(AppPermission.addProduct) ?? false;
          final canEdit = user?.can(AppPermission.editProduct) ?? false;
          final canDelete = user?.can(AppPermission.deleteProduct) ?? false;
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
                const SizedBox(height: 16),
                _buildStats(provider),
                const SizedBox(height: 16),
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
                      onEdit: canEdit
                          ? (p) async {
                              final updated = await showDialog<Product>(
                                context: context,
                                builder: (_) => ProductFormDialog(product: p),
                              );
                              if (updated != null) {
                                try {
                                  await provider.updateProduct(updated);
                                } catch (e) {
                                  if (mounted) {
                                    AppScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur mise à jour produit : $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                      onDelete: canDelete
                          ? (p) async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirmer la suppression'),
                                  content: Text('Supprimer ${p.name} ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await provider.deleteProduct(p.id);
                                } catch (e) {
                                  if (mounted) {
                                    AppScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur suppression produit : $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                      onBulkDelete: canDelete
                          ? (products) async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirmer la suppression'),
                                  content: Text(
                                    'Voulez-vous vraiment supprimer ces ${products.length} produit(s) ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Supprimer tout'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  for (final p in products) {
                                    await provider.deleteProduct(p.id);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AppScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur lors de la suppression par lot : $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(ProductProvider provider) {
    return PageStatCards(
      items: [
        PageStatCardData(
          label: 'Produits',
          value: '${provider.totalProducts}',
          color: Colors.indigo,
          icon: Icons.medication_outlined,
        ),
        PageStatCardData(
          label: 'Stock faible',
          value: '${provider.lowStockCount}',
          color: Colors.orange,
          icon: Icons.inventory_2_outlined,
        ),
        PageStatCardData(
          label: 'Rupture',
          value: '${provider.outOfStockCount}',
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        ),
        PageStatCardData(
          label: 'Expirés',
          value: '${provider.expiredCount}',
          color: Colors.redAccent,
          icon: Icons.event_busy_outlined,
        ),
        PageStatCardData(
          label: 'Bientôt expirés',
          value: '${provider.nearExpirationCount}',
          color: Colors.orange,
          icon: Icons.event_note_outlined,
        ),
      ],
    );
  }

  Widget _buildResponsiveHeader(BuildContext context, bool canAdd) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

        Widget searchField({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 380,
            height: 54,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: BpColors.textPrimary),
              decoration: BpInputTheme.light(
                label: 'Recherche',
                hint: 'Rechercher par nom ou catégorie',
                prefixIcon: Icons.search,
                showLabel: false,
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          );
        }

        Widget filterField({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 220,
            height: 54,
            child: DropdownButtonFormField<String>(
              value: _filter,
              isExpanded: true,
              dropdownColor: BpColors.surface,
              decoration: BpInputTheme.light(
                label: 'Filtre',
                hint: 'Tous les produits',
                showLabel: false,
              ),
              style: const TextStyle(
                color: BpColors.textPrimary,
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
              ],
              onChanged: (value) =>
                  setState(() => _filter = value ?? 'Tous les produits'),
            ),
          );
        }

        Widget scannerAction({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 170,
            height: 54,
            child: ScannerButton(
              style: ScannerButtonStyle.filled,
              tooltip: 'Scanner un produit',
              onProductScanned: _handleScannedProduct,
            ),
          );
        }

        Widget refreshAction({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 170,
            height: 54,
            child: FilledButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.surfaceMuted,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: BpColors.border),
                ),
              ),
            ),
          );
        }

        Widget addAction({required bool fullWidth}) {
          if (!canAdd) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: fullWidth ? double.infinity : 200,
            height: 54,
            child: FilledButton.icon(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.cardBg,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: BpColors.borderStrong),
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'GESTION DES PRODUITS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gérez les médicaments, le stock et les lots pharmaceutiques',
                      style: TextStyle(
                        color: BpColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    searchField(fullWidth: true),
                    const SizedBox(height: 12),
                    filterField(fullWidth: true),
                    const SizedBox(height: 12),
                    scannerAction(fullWidth: true),
                    const SizedBox(height: 12),
                    refreshAction(fullWidth: true),
                    if (canAdd) const SizedBox(height: 12),
                    if (canAdd) addAction(fullWidth: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'GESTION DES PRODUITS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: BpColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gérez les médicaments, le stock et les lots pharmaceutiques',
                            style: TextStyle(
                              color: BpColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: searchField(fullWidth: false),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: filterField(fullWidth: false)),
                    const SizedBox(width: 12),
                    SizedBox(width: 170, child: scannerAction(fullWidth: false)),
                    const SizedBox(width: 12),
                    SizedBox(width: 170, child: refreshAction(fullWidth: false)),
                    if (canAdd) ...[
                      const SizedBox(width: 12),
                      SizedBox(width: 200, child: addAction(fullWidth: false)),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final canAdd = authProvider.user?.can(AppPermission.addProduct) ?? false;
    return _buildResponsiveHeader(context, canAdd);

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
                      color: BpColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérez les médicaments, le stock et les lots pharmaceutiques',
                    style: TextStyle(
                      color: BpColors.textSecondary,
                      fontSize: 13,
                    ),
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
                      style: const TextStyle(color: BpColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: BpColors.textSecondary,
                        ),
                        hintText: 'Rechercher...',
                        hintStyle: const TextStyle(
                          color: BpColors.textHint,
                          fontSize: 14,
                        ),
                        isDense: true,
                        fillColor: BpColors.cardBg,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: BpColors.borderStrong,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: BpColors.border),
                        ),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: BpColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BpColors.borderStrong),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filter,
                        dropdownColor: BpColors.surface,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: BpColors.textSecondary,
                        ),
                        style: const TextStyle(
                          color: BpColors.textPrimary,
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
                  if (canAdd)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BpColors.cardBg,
                          foregroundColor: BpColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: BpColors.borderStrong,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (canAdd) const SizedBox(width: 8),
                  ScannerButton(
                    style: ScannerButtonStyle.icon,
                    tooltip: 'Scanner un produit',
                    onProductScanned: _handleScannedProduct,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadProducts,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualiser',
                    color: BpColors.textPrimary,
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
                        color: BpColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gérez les médicaments, le stock et les lots pharmaceutiques',
                      style: TextStyle(
                        color: BpColors.textSecondary,
                        fontSize: 13,
                      ),
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
                          style: const TextStyle(color: BpColors.textPrimary),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: BpColors.textSecondary,
                            ),
                            hintText: 'Rechercher par nom ou catégorie',
                            hintStyle: const TextStyle(
                              color: BpColors.textHint,
                              fontSize: 14,
                            ),
                            isDense: true,
                            fillColor: BpColors.cardBg,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: BpColors.borderStrong,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: BpColors.border,
                              ),
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
                        color: BpColors.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BpColors.borderStrong),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filter,
                          dropdownColor: BpColors.surface,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: BpColors.textSecondary,
                          ),
                          style: const TextStyle(
                            color: BpColors.textPrimary,
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
                          ],
                          onChanged: (v) => setState(
                            () => _filter = v ?? 'Tous les produits',
                          ),
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
                    ScannerButton(
                      style: ScannerButtonStyle.icon,
                      tooltip: 'Scanner un produit',
                      onProductScanned: _handleScannedProduct,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualiser les produits',
                      color: BpColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    if (canAdd)
                      ElevatedButton(
                        onPressed: _openAddDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BpColors.cardBg,
                          foregroundColor: BpColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: BpColors.borderStrong,
                            ),
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
