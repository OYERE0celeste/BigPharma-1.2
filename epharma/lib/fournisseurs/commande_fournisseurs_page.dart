import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_layout.dart';
import '../widgets/app_colors.dart';
import '../models/supplier_model.dart';
import '../models/product_model.dart';
import '../models/activity_model.dart';
import '../models/finance_model.dart';
import '../providers/supplier_order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/finance_provider.dart';

class SupplierOrderPage extends StatefulWidget {
  final Supplier supplier;

  const SupplierOrderPage({super.key, required this.supplier});

  @override
  State<SupplierOrderPage> createState() => _SupplierOrderPageState();
}

class _SupplierOrderPageState extends State<SupplierOrderPage> {
  final Map<String, OrderItem> _selectedItems = {};
  int _currentStep = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      pageTitle: 'Commande fournisseur',
      child: _currentStep == 1
          ? _buildProductSelectionPage()
          : _buildOrderSummaryPage(),
    );
  }

  Widget _buildProductSelectionPage() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productProvider.products;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        _buildTableHeader(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductRow(product);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nouvelle commande - ${widget.supplier.name}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez les produits à commander',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 50),
          Expanded(
            flex: 3,
            child: Text(
              'Produit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Stock actuel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Quantité',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    final orderItem = _selectedItems[product.id];
    final quantity = orderItem?.quantity ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: orderItem != null,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedItems[product.id] = OrderItem(
                    productId: product.id,
                    productName: product.name,
                    unitPrice: product.purchasePrice,
                    quantity: 1,
                  );
                } else {
                  _selectedItems.remove(product.id);
                }
              });
            },
          ),
          Expanded(flex: 3, child: Text(product.name)),
          Expanded(flex: 2, child: Text('${product.totalStock}')),
          Expanded(
            flex: 2,
            child: orderItem != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () {
                                setState(() {
                                  _selectedItems[product.id] = orderItem
                                      .copyWith(quantity: quantity - 1);
                                });
                              }
                            : null,
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text('$quantity'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _selectedItems[product.id] = orderItem.copyWith(
                              quantity: quantity + 1,
                            );
                          });
                        },
                      ),
                    ],
                  )
                : const Text('-'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Produits sélectionnés: ${_selectedItems.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        ElevatedButton(
          onPressed: _selectedItems.isNotEmpty && !_isLoading
              ? () => setState(() => _currentStep = 2)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryPage() {
    final items = _selectedItems.values.toList();
    final totalAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSupplierInfo(),
                      const SizedBox(height: 20),
                      _buildOrderItemsTable(items),
                      const SizedBox(height: 20),
                      _buildTotalSection(totalAmount),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryActions(totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bon de commande',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Vérifiez les détails de votre commande',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSupplierInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fournisseur: ${widget.supplier.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Contact: ${widget.supplier.contactName}'),
          Text('Téléphone: ${widget.supplier.phone}'),
          Text('Email: ${widget.supplier.email}'),
        ],
      ),
    );
  }

  Widget _buildOrderItemsTable(List<OrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produits commandés',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildItemsTableHeader(),
              ...items.map((item) => _buildItemRow(item)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Produit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Quantité',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Prix unitaire',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    final total = item.unitPrice * item.quantity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item.productName)),
          Expanded(flex: 1, child: Text('${item.quantity}')),
          Expanded(flex: 2, child: Text('${item.unitPrice} FCFA')),
          Expanded(flex: 2, child: Text('${total} FCFA')),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Total général:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Text(
            '${totalAmount.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryActions(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _currentStep = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Modifier'),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _validateOrder(totalAmount),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Valider la commande'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _validateOrder(double totalAmount) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = _selectedItems.values
          .map(
            (item) => SupplierOrderItem(
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice.toInt(),
              totalPrice: (item.unitPrice * item.quantity).toInt(),
            ),
          )
          .toList();

      await context.read<SupplierOrderProvider>().createOrder(
        supplierId: widget.supplier.id,
        supplierName: widget.supplier.name,
        items: items,
      );

      final activity = ActivityModel(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        type: ActivityType.restocking,
        reference: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
        clientOrSupplierName: widget.supplier.name,
        productName: 'Commande multiple',
        quantity: items.length,
        totalAmount: totalAmount.toDouble(),
        paymentMethod: PaymentMethod.transfer,
        employeeName: 'Utilisateur actuel',
        status: TransactionStatus.completed,
        listOfItems: items
            .map(
              (item) => TransactionItem(
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice.toDouble(),
                totalPrice: item.totalPrice.toDouble(),
              ),
            )
            .toList(),
        taxAmount: 0,
        notes: 'Commande fournisseur: ${widget.supplier.name}',
      );
      context.read<ActivityProvider>().addActivity(activity);

      context.read<FinanceProvider>().addTransaction(
        FinanceTransactionModel(
          id: 'TRANS-${DateTime.now().millisecondsSinceEpoch}',
          dateTime: DateTime.now(),
          type: 'Dépense',
          sourceModule: 'Commandes fournisseurs',
          reference: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
          description: 'Commande fournisseur: ${widget.supplier.name}',
          amount: totalAmount.toDouble(),
          isIncome: false,
          paymentMethod: 'Virement',
          employeeName: 'Utilisateur actuel',
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande créée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  OrderItem copyWith({int? quantity, double? unitPrice}) {
    return OrderItem(
      productId: productId,
      productName: productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
