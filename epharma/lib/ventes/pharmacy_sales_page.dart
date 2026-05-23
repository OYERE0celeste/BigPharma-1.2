import '../models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/product_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/bp_theme.dart';
import '../widgets/page_stat_cards.dart';
import '../widgets/receipt_ticket.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/sale_model.dart';
import '../security/rbac.dart';
import '../commandes/order_details_page.dart';
import '../services/order_invoice_service.dart';
import '../services/receipt_export_service.dart';
import 'widgets/product_card.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/transaction_summary.dart';
import '../scanner/widgets/scanner_button.dart';
import 'widgets/payment_section.dart';
import 'widgets/sale_history.dart';
import 'services/auto_cart_manager.dart';
import '../scanner/services/scanner_context_handler.dart';

// ============================================================================
// MAIN PAGE
// ============================================================================

class PharmacySalesPage extends StatefulWidget {
  const PharmacySalesPage({super.key});

  @override
  State<PharmacySalesPage> createState() => _PharmacySalesPageState();
}

class _PharmacySalesPageState extends State<PharmacySalesPage> {
  final List<CartItem> _cart = [];
  late TextEditingController _searchController;
  late AutoCartManager _autoCartManager;

  bool _showSalesHistory = false;

  double _customDiscount = 0;
  double _customTax = 0;
  double _amountReceived = 0;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  double get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // ========== INITIALIZE AUTO CART MANAGER ==========
    // Listen to ProductFound events and auto-add to cart
    _autoCartManager = AutoCartManager(
      cartItems: _cart,
      onCartChanged: () {
        setState(() {}); // Rebuild when cart changes
      },
    );

    // ========== SET SCANNER CONTEXT ==========
    // Tell scanner system we're on Sales page
    ScannerContextHandler.instance.setActivePage(
      ScannerActivePageContext.sales,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _autoCartManager.dispose(); // Clean up auto-cart manager
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {}); // Trigger rebuild to apply filter in build method
  }

  Future<void> _loadInitialData() async {
    final productProvider = context.read<ProductProvider>();
    final salesProvider = context.read<SalesProvider>();

    if (productProvider.products.isEmpty) {
      await productProvider.loadProducts();
    }
    if (salesProvider.sales.isEmpty) {
      await salesProvider.loadSales();
    }

    await _loadOrderHistory();
  }

  Future<void> _loadOrderHistory({bool forceRefresh = false}) async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.token == null) {
      return;
    }

    await context.read<OrderProvider>().fetchOrders(
      authProvider: authProvider,
      forceRefresh: forceRefresh,
    );
  }

  void _openSalesHistory() {
    setState(() => _showSalesHistory = true);
    _loadOrderHistory();
  }

  void _openOrderDetails(String orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: orderId)),
    );
  }

  void _openSaleDetails(Sale sale) {
    final receipt = ReceiptTicketFactory.fromSale(sale);

    showDialog<void>(
      context: context,
      builder: (context) => ReceiptPreviewDialog(
        title: 'Facture ${sale.invoiceNumber}',
        data: receipt,
        onDownload: () =>
            _downloadReceipt(receipt, filename: '${sale.invoiceNumber}.pdf'),
      ),
    );
  }

  Future<void> _downloadSaleReceipt(Sale sale) async {
    await _downloadReceipt(
      ReceiptTicketFactory.fromSale(sale),
      filename: '${sale.invoiceNumber}.pdf',
    );
  }

  Future<void> _downloadOrderReceipt(OrderModel order) async {
    try {
      final invoice = await OrderInvoiceService.fetchOrderInvoice(order.id);
      final receipt = invoice != null
          ? ReceiptTicketFactory.fromOrderInvoice(
              invoice,
              operatorName: order.userName,
            )
          : ReceiptTicketFactory.fromOrder(order);

      await _downloadReceipt(receipt, filename: '${receipt.invoiceNumber}.pdf');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de telecharger la facture: $error')),
      );
    }
  }

  Future<void> _downloadReceipt(
    ReceiptTicketData receipt, {
    required String filename,
  }) async {
    try {
      await ReceiptExportService.downloadReceipt(receipt, filename: filename);
      if (!mounted) {
        return;
      }
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture prete pour telechargement.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du telechargement: $error')),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSalesStats(
    ProductProvider productProvider,
    SalesProvider salesProvider,
  ) {
    final now = DateTime.now();
    final todaySales = salesProvider.sales
        .where((sale) => _isSameDay(sale.dateTime, now))
        .toList();
    final todayRevenue = todaySales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final cartQuantity = _cart.fold<int>(0, (sum, item) => sum + item.quantity);

    return PageStatCards(
      items: [
        PageStatCardData(
          label: 'Produits',
          value: '${productProvider.totalProducts}',
          color: Colors.indigo,
          icon: Icons.medication_outlined,
        ),
        PageStatCardData(
          label: 'Panier',
          value: '${_cart.length}',
          color: Colors.orange,
          icon: Icons.shopping_cart_outlined,
        ),
        PageStatCardData(
          label: 'Articles',
          value: '$cartQuantity',
          color: Colors.blue,
          icon: Icons.shopping_bag_outlined,
        ),
        PageStatCardData(
          label: 'Ventes du jour',
          value: '${todaySales.length}',
          color: Colors.green,
          icon: Icons.receipt_long_outlined,
        ),
        PageStatCardData(
          label: 'CA du jour',
          value: '${todayRevenue.toStringAsFixed(0)} FCFA',
          color: Colors.teal,
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  void _addProductToCart(Product product) {
    final lot = product.nearestExpirationLot;

    if (product.availableStock == 0 || lot == null) {
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun lot disponible pour ce produit.')),
      );
      return;
    }

    final existingIndex = _cart.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedLot.lotNumber == lot.lotNumber,
    );

    if (existingIndex >= 0) {
      final existingItem = _cart[existingIndex];
      setState(() {
        if (existingItem.quantity < lot.quantityAvailable) {
          existingItem.quantity++;
        }
      });
    } else {
      setState(() {
        _cart.add(CartItem(product: product, selectedLot: lot, quantity: 1));
      });
    }

    AppScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajoute au panier'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cart.remove(item);
    });
  }

  Future<void> _confirmSale() async {
    // Validations
    if (_cart.isEmpty) {
      AppScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le panier est vide')));
      return;
    }

    if (_amountReceived < _cartSubtotal - _customDiscount + _customTax) {
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant de paiement insuffisant')),
      );
      return;
    }

    try {
      final sale = await context.read<SalesProvider>().createSale(
        items: List.from(_cart),
        discountAmount: _customDiscount,
        taxAmount: _customTax,
        paymentMethod: _selectedPaymentMethod.toString().split('.').last,
        amountReceived: _amountReceived,
      );

      if (sale == null) {
        throw Exception('Vente invalide');
      }

      await context.read<ProductProvider>().loadProducts();
      await context.read<FinanceProvider>().loadTransactions();

      setState(() {
        _cart.clear();
        _customDiscount = 0;
        _customTax = 0;
        _amountReceived = 0;

        _selectedPaymentMethod = PaymentMethod.cash;
      });

      _showSuccessDialog(sale);
    } catch (error) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création de la vente: $error'),
        ),
      );
    }
  }

  void _showSuccessDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✓ Vente Confirmée'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text('Facture : ${sale.invoiceNumber}'),
              Text('Articles : ${sale.items.length}'),
              Text('Total : ${sale.totalAmount.toStringAsFixed(0)} FCFA'),
              Text('Paiement : ${sale.paymentMethod}'),
              Text('Monnaie : ${sale.changeAmount.toStringAsFixed(0)} FCFA'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _downloadSaleReceipt(sale);
              if (!mounted) {
                return;
              }
              _openSaleDetails(sale);
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Voir / Telecharger'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final productProvider = context.watch<ProductProvider>();
    final salesProvider = context.watch<SalesProvider>();
    final canMakeSale = user?.can(AppPermission.makeSale) ?? false;
    final canViewHistory = user?.can(AppPermission.viewSalesHistory) ?? false;

    if (!canMakeSale && !canViewHistory) {
      return const Center(child: Text('Acces non autorise a ce module.'));
    }

    if ((productProvider.isLoading && productProvider.products.isEmpty) ||
        (salesProvider.isLoading && salesProvider.sales.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(color: BpColors.accent),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Increased threshold to 1100 for better tablet/small laptop support
        if (constraints.maxWidth < 1100) {
          return _buildMobilePOSView(
            constraints,
            productProvider: productProvider,
            salesProvider: salesProvider,
            canMakeSale: canMakeSale,
            canViewHistory: canViewHistory,
          );
        }
        if (!canMakeSale && canViewHistory) {
          return _buildSalesDesktopShell(
            stats: _buildSalesStats(productProvider, salesProvider),
            child: _buildSalesHistoryView(canReturnToPos: false),
          );
        }
        return _buildSalesDesktopShell(
          stats: _buildSalesStats(productProvider, salesProvider),
          child: _showSalesHistory
              ? _buildSalesHistoryView(canReturnToPos: canMakeSale)
              : _buildPOSView(
                  canMakeSale: canMakeSale,
                  canViewHistory: canViewHistory,
                ),
        );
      },
    );
  }

  Widget _buildSalesDesktopShell({
    required Widget stats,
    required Widget child,
  }) {
    return Container(
      color: BpColors.scaffoldSecondary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: stats,
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobilePOSView(
    BoxConstraints constraints, {
    required ProductProvider productProvider,
    required SalesProvider salesProvider,
    required bool canMakeSale,
    required bool canViewHistory,
  }) {
    if (_showSalesHistory || !canMakeSale) {
      return Container(
        color: BpColors.scaffoldSecondary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSalesStats(productProvider, salesProvider),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildSalesHistoryView(canReturnToPos: canMakeSale),
            ),
          ],
        ),
      );
    }

    // Simple tabbed view for mobile: Products vs Cart
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: BpColors.surfaceStrong,
          foregroundColor: BpColors.textPrimary,
          title: const Text('Point de Vente', style: TextStyle(fontSize: 16)),
          actions: [
            ScannerButton(
              style: ScannerButtonStyle.icon,
              tooltip: 'Scanner et ajouter au panier',
              onProductScanned: (product) {
                _addProductToCart(product);
                AppScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produit ajouté au panier : ${product.name}'),
                  ),
                );
              },
            ),
            if (canViewHistory)
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _openSalesHistory,
              ),
          ],
          bottom: const TabBar(
            labelColor: BpColors.textPrimary,
            unselectedLabelColor: BpColors.textSecondary,
            indicatorColor: BpColors.accent,
            tabs: [
              Tab(text: 'Produits', icon: Icon(Icons.grid_view)),
              Tab(text: 'Panier', icon: Icon(Icons.shopping_cart)),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSalesStats(productProvider, salesProvider),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductsSection(isMobile: true),
                  _buildCartSection(isMobile: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPOSView({
    required bool canMakeSale,
    required bool canViewHistory,
  }) {
    return Row(
      children: [
        // LEFT SIDE: Product Search & Selection
        _buildProductsSection(
          isMobile: false,
          canMakeSale: canMakeSale,
          canViewHistory: canViewHistory,
        ),
        // RIGHT SIDE: Cart & Transaction Summary
        _buildCartSection(isMobile: false),
      ],
    );
  }

  Widget _buildProductsSection({
    required bool isMobile,
    bool canMakeSale = true,
    bool canViewHistory = true,
  }) {
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;
    final query = _searchController.text.toLowerCase();

    List<Product> filteredProducts = allProducts;
    if (query.isNotEmpty) {
      filteredProducts = allProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query) ||
                p.id.toLowerCase().contains(query),
          )
          .toList();
    }

    return Expanded(
      flex: isMobile ? 1 : 2,
      child: Container(
        color: BpColors.scaffoldSecondary,
        child: Column(
          children: [
            if (!isMobile) // Header only for desktop
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1100) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BpColors.surfaceStrong,
                        border: const Border(
                          bottom: BorderSide(color: BpColors.border),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'POINT DE VENTE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: BpColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            onChanged: _filterProducts,
                            style: const TextStyle(color: BpColors.textPrimary),
                            decoration: BpInputTheme.light(
                              label: 'Rechercher un produit',
                              hint: 'Nom, categorie ou ID...',
                              prefixIcon: Icons.search,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildHeaderBtn(
                                  label: 'Vente',
                                  icon: Icons.shopping_bag,
                                  isActive: !_showSalesHistory,
                                  onPressed: canMakeSale
                                      ? () => setState(
                                          () => _showSalesHistory = false,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (canViewHistory)
                                Expanded(
                                  child: _buildHeaderBtn(
                                    label: 'Historique',
                                    icon: Icons.history,
                                    isActive: _showSalesHistory,
                                    onPressed: _openSalesHistory,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: BpColors.surfaceStrong,
                      border: const Border(
                        bottom: BorderSide(color: BpColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left: Title
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'POINT DE VENTE',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: BpColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gerez vos ventes quotidiennes',
                                style: TextStyle(
                                  color: BpColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Middle: Search
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterProducts,
                                    style: const TextStyle(
                                      color: BpColors.textPrimary,
                                    ),
                                    decoration: BpInputTheme.light(
                                      label: 'Rechercher un produit',
                                      hint: 'Nom, categorie ou ID...',
                                      prefixIcon: Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right: Actions
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ScannerButton(
                                style: ScannerButtonStyle.filled,
                                tooltip: 'Scanner et ajouter au panier',
                                onProductScanned: (product) {
                                  _addProductToCart(product);
                                  AppScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Produit ajouté au panier : ${product.name}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildHeaderBtn(
                                label: 'Nouvelle Vente',
                                icon: Icons.shopping_bag,
                                isActive: !_showSalesHistory,
                                onPressed: canMakeSale
                                    ? () => setState(
                                        () => _showSalesHistory = false,
                                      )
                                    : null,
                              ),
                              if (canViewHistory) ...[
                                const SizedBox(width: 8),
                                _buildHeaderBtn(
                                  label: 'Historique',
                                  icon: Icons.history,
                                  isActive: _showSalesHistory,
                                  onPressed: _openSalesHistory,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            // Products grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossCount = 3;
                  double ratio = 0.7; // Lower ratio to give more vertical space

                  if (width < 500) {
                    crossCount = 1;
                    ratio = 1.8;
                  } else if (width < 800) {
                    crossCount = 2;
                    ratio = 0.8;
                  } else if (width < 1200) {
                    crossCount = 3;
                    ratio = 0.7;
                  } else {
                    crossCount = 4;
                    ratio = 0.75;
                  }

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun produit ne correspond a votre recherche.',
                        style: TextStyle(color: BpColors.textSecondary),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: ratio,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final p = filteredProducts[index];
                      return ProductCard(
                        product: p,
                        onAddToCart: canMakeSale
                            ? () => _addProductToCart(p)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive
            ? BpColors.textPrimary
            : BpColors.textSecondary,
        backgroundColor: isActive
            ? BpColors.accent.withOpacity(0.14)
            : BpColors.surfaceStrong,
        side: BorderSide(
          color: isActive ? BpColors.accent : BpColors.borderStrong,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCartSection({required bool isMobile}) {
    return Expanded(
      flex: 1,
      child: Container(
        color: BpColors.surfaceStrong,
        child: Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BpColors.surfaceStrong,
                border: const Border(
                  bottom: BorderSide(color: BpColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PANIER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
                  ),
                  if (_cart.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() => _cart.clear()),
                      icon: const Icon(Icons.delete_sweep, size: 16),
                      label: const Text('Vider'),
                      style: TextButton.styleFrom(foregroundColor: kDangerRed),
                    ),
                ],
              ),
            ),
            // Cart Items & Payment Footer in a single scrollable view to prevent overflow on small screens
            Expanded(
              child: _cart.isEmpty
                  ? _buildEmptyCart()
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ..._cart.map((item) {
                          return CartItemTile(
                            cartItem: item,
                            onIncrement: () => setState(() {
                              if (item.quantity <
                                  item.selectedLot.quantityAvailable) {
                                item.quantity++;
                              }
                            }),
                            onDecrement: () => setState(() {
                              if (item.quantity > 1) {
                                item.quantity--;
                              }
                            }),
                            onRemove: () => _removeFromCart(item),
                          );
                        }),
                        _buildCartFooter(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 48,
            color: BpColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Le panier est vide',
            style: TextStyle(color: BpColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransactionSummaryPanel(
            subtotal: _cartSubtotal,
            discount: _customDiscount,
            tax: _customTax,
            onDiscountChanged: (v) => setState(() => _customDiscount = v),
          ),
          PaymentSection(
            totalAmount: _cartSubtotal - _customDiscount + _customTax,
            selectedPaymentMethod: _selectedPaymentMethod,
            onPaymentMethodChanged: (m) =>
                setState(() => _selectedPaymentMethod = m),
            onAmountReceivedChanged: (a) => setState(() => _amountReceived = a),
            amountReceived: _amountReceived,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _confirmSale,
              icon: const Icon(Icons.check_circle),
              label: const Text('CONFIRMER LA VENTE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesHistoryView({required bool canReturnToPos}) {
    final orderProvider = context.watch<OrderProvider>();

    return Container(
      color: BpColors.scaffoldSecondary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'HISTORIQUE DES VENTES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
                  ),
                ),
                if (canReturnToPos) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showSalesHistory = false);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Retour au POS'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SaleHistoryTable(
              sales: context.watch<SalesProvider>().sales,
              orders: orderProvider.orders,
              isLoadingOrders: orderProvider.isLoading,
              ordersErrorMessage: orderProvider.errorMessage,
              onRefreshOrders: () => _loadOrderHistory(forceRefresh: true),
              onOpenSale: _openSaleDetails,
              onDownloadSale: _downloadSaleReceipt,
              onOpenOrder: (order) => _openOrderDetails(order.id),
              onDownloadOrder: _downloadOrderReceipt,
            ),
          ),
        ],
      ),
    );
  }
}
