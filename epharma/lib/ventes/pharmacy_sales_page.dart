import '../models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
import 'package:intl/intl.dart';
import '../pharmacy_dashboard_page.dart';
import '../products/pharmacy_products_page.dart';
import '../clients/pharmacy_clients_page.dart';
import '../activites/pharmacy_activity_register_page.dart';
import '../providers/sales_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final bool isSelected;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = product.stockStatus;
    final availableStock = product.availableStock;

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? kSoftBlue : Colors.white,
      child: InkWell(
        onTap: availableStock > 0 ? onAddToCart : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (product.prescriptionRequired)
                    Tooltip(
                      message: 'Prescription Required',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kDangerRed, width: 1),
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kDangerRed,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.category,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              StatusBadge(status: status),
              const SizedBox(height: 6),
              Text(
                'Stock: $availableStock',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                  if (availableStock > 0)
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final StockStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case StockStatus.available:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Available';
        icon = Icons.check_circle;
        break;
      case StockStatus.lowStock:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Low Stock';
        icon = Icons.warning;
        break;
      case StockStatus.outOfStock:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Out of Stock';
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lot: ${cartItem.selectedLot.lotNumber}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: \$${cartItem.product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${cartItem.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: cartItem.quantity > 1 ? onDecrement : null,
                        child: Icon(
                          Icons.remove_circle,
                          size: 18,
                          color: cartItem.quantity > 1
                              ? kPrimaryGreen
                              : Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:
                            cartItem.quantity <
                                cartItem.selectedLot.quantityAvailable
                            ? onIncrement
                            : null,
                        child: Icon(
                          Icons.add_circle,
                          size: 18,
                          color:
                              cartItem.quantity <
                                  cartItem.selectedLot.quantityAvailable
                              ? kPrimaryGreen
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: kDangerRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrescriptionBanner extends StatelessWidget {
  final bool isVerified;
  final VoidCallback onAttach;
  final ValueChanged<bool> onVerificationToggle;

  const PrescriptionBanner({
    super.key,
    required this.isVerified,
    required this.onAttach,
    required this.onVerificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: kDangerRed, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: kDangerRed, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This cart contains prescription-required items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kDangerRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAttach,
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text('Attach Prescription'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kDangerRed),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verified', style: TextStyle(fontSize: 11)),
                  value: isVerified,
                  onChanged: (value) => onVerificationToggle(value ?? false),
                  activeColor: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionSummaryPanel extends StatefulWidget {
  final double subtotal;
  final ValueChanged<double> onDiscountChanged;
  final double discount;
  final double tax;

  const TransactionSummaryPanel({
    super.key,
    required this.subtotal,
    required this.onDiscountChanged,
    required this.discount,
    required this.tax,
  });

  @override
  State<TransactionSummaryPanel> createState() =>
      _TransactionSummaryPanelState();
}

class _TransactionSummaryPanelState extends State<TransactionSummaryPanel> {
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.discount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.subtotal - widget.discount + widget.tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${widget.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                widget.onDiscountChanged(double.tryParse(value) ?? 0),
            decoration: InputDecoration(
              labelText: 'Discount (\$)',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tax',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${widget.tax.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentSection extends StatefulWidget {
  final double totalAmount;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final ValueChanged<double> onAmountReceivedChanged;
  final double amountReceived;

  const PaymentSection({
    super.key,
    required this.totalAmount,
    required this.onPaymentMethodChanged,
    required this.onAmountReceivedChanged,
    required this.amountReceived,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  late TextEditingController _amountReceivedController;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _amountReceivedController = TextEditingController(
      text: widget.amountReceived.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeAmount = widget.amountReceived - widget.totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SegmentedButton<PaymentMethod>(
            segments: const [
              ButtonSegment(
                value: PaymentMethod.cash,
                label: Text('Cash'),
                icon: Icon(Icons.payments),
              ),
              ButtonSegment(
                value: PaymentMethod.card,
                label: Text('Card'),
                icon: Icon(Icons.credit_card),
              ),
              ButtonSegment(
                value: PaymentMethod.mobileMoney,
                label: Text('Mobile Money'),
                icon: Icon(Icons.phone_android),
              ),
            ],
            selected: {_selectedPaymentMethod},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedPaymentMethod = newSelection.first;
              });
              widget.onPaymentMethodChanged(_selectedPaymentMethod);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountReceivedController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.onAmountReceivedChanged(double.tryParse(value) ?? 0);
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Amount Received (\$)',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: changeAmount > 0
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: changeAmount > 0 ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${changeAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: changeAmount > 0
                        ? Colors.green.shade700
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SaleHistoryTable extends StatefulWidget {
  final List<Sale> sales;

  const SaleHistoryTable({super.key, required this.sales});

  @override
  State<SaleHistoryTable> createState() => _SaleHistoryTableState();
}

class _SaleHistoryTableState extends State<SaleHistoryTable> {
  late List<Sale> _filteredSales;
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _filteredSales = widget.sales;
  }

  void _updateFilters() {
    _filteredSales = widget.sales.where((sale) {
      if (_selectedDate != null) {
        final saleDate = DateTime(
          sale.dateTime.year,
          sale.dateTime.month,
          sale.dateTime.day,
        );
        final selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        if (saleDate != selectedDate) return false;
      }

      if (_selectedPaymentMethod != null &&
          sale.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      return true;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (selected != null) {
                      setState(() => _selectedDate = selected);
                      _updateFilters();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate == null
                        ? 'Filter by Date'
                        : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              if (_selectedDate != null)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _selectedDate = null);
                    _updateFilters();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Date'),
                ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('Invoice')),
                  DataColumn(label: Text('Date & Time')),
                  DataColumn(label: Text('Total'), numeric: true),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Pharmacist')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredSales.map((sale) {
                  return DataRow(
                    cells: [
                      DataCell(Text(sale.invoiceNumber)),
                      DataCell(
                        Text(
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(sale.dateTime),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${sale.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(sale.paymentMethod)),
                      DataCell(Text(sale.pharmacistName)),
                      DataCell(
                        Tooltip(
                          message: 'View Details',
                          child: Icon(
                            Icons.visibility,
                            size: 16,
                            color: kPrimaryGreen,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          if (_filteredSales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No sales history found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
