import 'package:epharma/ventes/widgets/prescription_banner.dart';

import '../models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
//import 'package:intl/intl.dart';
import '../pharmacy_dashboard_page.dart';
import '../products/pharmacy_products_page.dart';
import '../clients/pharmacy_clients_page.dart';
import '../activites/activity_register_page.dart';
import '../providers/sales_provider.dart';
import '../providers/product_provider.dart';
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
  late List<Product> _allProducts;
  late List<Product> _filteredProducts;
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
    _allProducts = [];
    _filteredProducts = _allProducts;
    _searchController = TextEditingController();
    _filterController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productProvider = Provider.of<ProductProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    _allProducts = productProvider.products;
    _filteredProducts = _allProducts;
    salesProvider.setProducts(_allProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.category.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  product.id.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _addProductToCart(Product product) {
    if (product.availableStock == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product is out of stock')));
      return;
    }

    if (product.prescriptionRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ This product requires a prescription'),
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
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cart.remove(item);
    });
  }

  void _confirmSale() {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Validations
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    if (_hasPrescriptionRequiredItems && !_prescriptionVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify prescription before confirming sale'),
        ),
      );
      return;
    }

    if (_amountReceived < _cartSubtotal - _customDiscount + _customTax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient payment amount')),
      );
      return;
    }

    // Create sale via provider
    final sale = salesProvider.createSale(
      items: List.from(_cart),
      discountAmount: _customDiscount,
      taxAmount: _customTax,
      paymentMethod: _selectedPaymentMethod.toString().split('.').last,
      amountReceived: _amountReceived,
      prescriptionVerified: _prescriptionVerified,
    );

    // Deduct stock
    for (final item in _cart) {
      productProvider.updateStock(
        item.product.id,
        item.selectedLot.lotNumber,
        -item.quantity,
      );
    }

    // Clear cart and reset
    setState(() {
      _cart.clear();
      _customDiscount = 0;
      _customTax = 0;
      _amountReceived = 0;
      _prescriptionVerified = false;
      _selectedPaymentMethod = PaymentMethod.cash;
    });

    // Show success dialog
    _showSuccessDialog(sale);
  }

  void _showSuccessDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✓ Sale Confirmed'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text('Invoice: ${sale.invoiceNumber}'),
              Text('Items: ${sale.items.length}'),
              Text('Total: \$${sale.totalAmount.toStringAsFixed(2)}'),
              Text('Payment: ${sale.paymentMethod}'),
              Text('Change: \$${sale.changeAmount.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Prepare invoice for printing/download
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Invoice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedLabel: 'Sales',
            callbacks: {
              'Dashboard': () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PharmacyDashboardPage(),
                ),
              ),
              'Stock': () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PharmacyProductsPage()),
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
            child: _showSalesHistory
                ? _buildSalesHistoryView()
                : _buildPOSView(),
          ),
        ],
      ),
    );
  }

  Widget _buildPOSView() {
    return Row(
      children: [
        // LEFT SIDE: Product Search & Selection
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Header with tab switcher
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'POS - SALES',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _showSalesHistory = false);
                            },
                            icon: const Icon(Icons.shopping_bag, size: 16),
                            label: const Text('New Sale'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _showSalesHistory
                                  ? Colors.transparent
                                  : kSoftBlue,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _showSalesHistory = true);
                            },
                            icon: const Icon(Icons.history, size: 16),
                            label: const Text('History'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _showSalesHistory
                                  ? kSoftBlue
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Search bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText:
                          'Search by product name, barcode, or category...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Products grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isInCart = _cart.any(
                          (item) => item.product.id == product.id,
                        );

                        return ProductCard(
                          product: product,
                          isSelected: isInCart,
                          onAddToCart: () => _addProductToCart(product),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // RIGHT SIDE: Cart & Transaction Summary
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SHOPPING CART',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_cart.length} item(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (_cart.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _cart.clear()),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kDangerRed,
                          ),
                        ),
                    ],
                  ),
                ),
                // Cart Items
                Expanded(
                  child: _cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Cart is empty',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Prescription Banner
                              if (_hasPrescriptionRequiredItems)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: PrescriptionBanner(
                                    isVerified: _prescriptionVerified,
                                    onAttach: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Prescription attachment feature coming soon',
                                          ),
                                        ),
                                      );
                                    },
                                    onVerificationToggle: (verified) {
                                      setState(
                                        () => _prescriptionVerified = verified,
                                      );
                                    },
                                  ),
                                ),
                              // Cart items
                              ..._cart.map(
                                (item) => CartItemTile(
                                  cartItem: item,
                                  onIncrement: () {
                                    setState(() {
                                      if (item.quantity <
                                          item.selectedLot.quantityAvailable) {
                                        item.quantity++;
                                      }
                                    });
                                  },
                                  onDecrement: () {
                                    setState(() {
                                      if (item.quantity > 1) {
                                        item.quantity--;
                                      }
                                    });
                                  },
                                  onRemove: () => _removeFromCart(item),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // Transaction Summary
                if (_cart.isNotEmpty) ...[
                  TransactionSummaryPanel(
                    subtotal: _cartSubtotal,
                    discount: _customDiscount,
                    tax: _customTax,
                    onDiscountChanged: (value) {
                      setState(() => _customDiscount = value);
                    },
                  ),
                  // Payment Section
                  PaymentSection(
                    totalAmount: _cartSubtotal - _customDiscount + _customTax,
                    onPaymentMethodChanged: (method) {
                      setState(() => _selectedPaymentMethod = method);
                    },
                    onAmountReceivedChanged: (amount) {
                      setState(() => _amountReceived = amount);
                    },
                    amountReceived: _amountReceived,
                  ),
                  // Confirm Sale Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _confirmSale,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('CONFIRM SALE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
                'SALES HISTORY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _showSalesHistory = false);
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Back to POS'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SaleHistoryTable(
              sales: Provider.of<SalesProvider>(context).sales,
            ),
          ),
        ],
      ),
    );
  }
}
