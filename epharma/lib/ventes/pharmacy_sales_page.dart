import 'package:epharma/ventes/widgets/prescription_banner.dart';

import '../models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../providers/product_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_colors.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import 'widgets/product_card.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/transaction_summary.dart';
import 'widgets/payment_section.dart';
import 'widgets/sale_history.dart';

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
  late TextEditingController _filterController;

  bool _showSalesHistory = false;
  bool _prescriptionVerified = false;
  double _customDiscount = 0;
  double _customTax = 0;
  double _amountReceived = 0;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  bool get _hasPrescriptionRequiredItems =>
      _cart.any((item) => item.product.prescriptionRequired);

  double get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {}); // Trigger rebuild to apply filter in build method
  }

  void _addProductToCart(Product product) {
    if (product.availableStock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit est en rupture de stock')),
      );
      return;
    }

    if (product.prescriptionRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Ce produit require une ordonnance'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final existingItem = _cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(
        product: product,
        selectedLot: product.nearestExpirationLot!,
        quantity: 1,
      ),
    );

    if (_cart.contains(existingItem)) {
      setState(() {
        if (existingItem.quantity <
            existingItem.selectedLot.quantityAvailable) {
          existingItem.quantity++;
        }
      });
    } else {
      setState(() {
        _cart.add(existingItem);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le panier est vide')));
      return;
    }

    if (_hasPrescriptionRequiredItems && !_prescriptionVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez vérifier l\'ordonnance avant de confirmer la vente',
          ),
        ),
      );
      return;
    }

    if (_amountReceived < _cartSubtotal - _customDiscount + _customTax) {
      ScaffoldMessenger.of(context).showSnackBar(
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
        prescriptionVerified: _prescriptionVerified,
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
        _prescriptionVerified = false;
        _selectedPaymentMethod = PaymentMethod.cash;
      });

      _showSuccessDialog(sale);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulation d\'impression de la facture...'),
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Imprimer la Facture'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Increased threshold to 1100 for better tablet/small laptop support
        if (constraints.maxWidth < 1100) {
          return _buildMobilePOSView(constraints);
        }
        return _showSalesHistory ? _buildSalesHistoryView() : _buildPOSView();
      },
    );
  }

  Widget _buildMobilePOSView(BoxConstraints constraints) {
    if (_showSalesHistory) return _buildSalesHistoryView();
    
    // Simple tabbed view for mobile: Products vs Cart
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Point de Vente', style: TextStyle(fontSize: 16)),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => setState(() => _showSalesHistory = true),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Produits', icon: Icon(Icons.grid_view)),
              Tab(text: 'Panier', icon: Icon(Icons.shopping_cart)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductsSection(isMobile: true),
            _buildCartSection(isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPOSView() {
    return Row(
      children: [
        // LEFT SIDE: Product Search & Selection
        _buildProductsSection(isMobile: false),
        // RIGHT SIDE: Cart & Transaction Summary
        _buildCartSection(isMobile: false),
      ],
    );
  }

  Widget _buildProductsSection({required bool isMobile}) {
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;
    final query = _searchController.text.toLowerCase();
    
    List<Product> filteredProducts = allProducts;
    if (query.isNotEmpty) {
      filteredProducts = allProducts
          .where((p) => p.name.toLowerCase().contains(query) || 
                         p.category.toLowerCase().contains(query) || 
                         p.id.toLowerCase().contains(query))
          .toList();
    }

    return Expanded(
      flex: isMobile ? 1 : 2,
      child: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            if (!isMobile) // Header only for desktop
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1100) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
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
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            onChanged: _filterProducts,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, size: 20),
                              hintText: 'Rechercher un produit...',
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
                                  onPressed: () => setState(
                                      () => _showSalesHistory = false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildHeaderBtn(
                                  label: 'Historique',
                                  icon: Icons.history,
                                  isActive: _showSalesHistory,
                                  onPressed: () => setState(
                                      () => _showSalesHistory = true),
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
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
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
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gérez vos ventes quotidiennes et ordonnances',
                                style: TextStyle(
                                  color: Colors.grey[600],
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
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterProducts,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.search, size: 20),
                                      hintText:
                                          'Rechercher un produit, catégorie ou ID...',
                                      hintStyle: const TextStyle(fontSize: 14),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
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
                              _buildHeaderBtn(
                                label: 'Nouvelle Vente',
                                icon: Icons.shopping_bag,
                                isActive: !_showSalesHistory,
                                onPressed: () =>
                                    setState(() => _showSalesHistory = false),
                              ),
                              const SizedBox(width: 8),
                              _buildHeaderBtn(
                                label: 'Historique',
                                icon: Icons.history,
                                isActive: _showSalesHistory,
                                onPressed: () =>
                                    setState(() => _showSalesHistory = true),
                              ),
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
                  
                  if (width < 500) { crossCount = 1; ratio = 1.8; }
                  else if (width < 800) { crossCount = 2; ratio = 0.8; }
                  else if (width < 1200) { crossCount = 3; ratio = 0.7; }
                  else { crossCount = 4; ratio = 0.75; }

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
                        isSelected: _cart.any((item) => item.product.id == p.id),
                        onAddToCart: () => _addProductToCart(p),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBtn({required String label, required IconData icon, required bool isActive, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? kSoftBlue : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCartSection({required bool isMobile}) {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PANIER', style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Cart Items
            Expanded(
              child: _cart.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Column(
                          children: [
                            if (index == 0 && _hasPrescriptionRequiredItems)
                              _buildPrescriptionBanner(),
                            CartItemTile(
                              cartItem: item,
                              onIncrement: () => setState(() {
                                if (item.quantity < item.selectedLot.quantityAvailable) item.quantity++;
                              }),
                              onDecrement: () => setState(() {
                                if (item.quantity > 1) item.quantity--;
                              }),
                              onRemove: () => _removeFromCart(item),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            // Footer (Total & Payment)
            if (_cart.isNotEmpty) _buildCartFooter(),
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
          Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Le panier est vide', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionBanner() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PrescriptionBanner(
        isVerified: _prescriptionVerified,
        onAttach: () {},
        onVerificationToggle: (v) => setState(() => _prescriptionVerified = v),
      ),
    );
  }

  Widget _buildCartFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
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
            onPaymentMethodChanged: (m) => setState(() => _selectedPaymentMethod = m),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesHistoryView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HISTORIQUE DES VENTES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _showSalesHistory = false);
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Retour au POS'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SaleHistoryTable(
              sales: context.watch<SalesProvider>().sales,
            ),
          ),
        ],
      ),
    );
  }
}
