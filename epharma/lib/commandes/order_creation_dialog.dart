import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/client_model.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/client_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/app_notification.dart';
import '../widgets/bp_theme.dart';
import '../widgets/common/app_ui.dart';

class OrderCreationDialog extends StatefulWidget {
  const OrderCreationDialog({super.key});

  @override
  State<OrderCreationDialog> createState() => _OrderCreationDialogState();
}

class _OrderCreationDialogState extends State<OrderCreationDialog> {
  Client? _selectedClient;
  Product? _selectedProduct;
  final List<Map<String, dynamic>> _cartItems = [];
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _total => _cartItems.fold(
        0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return AppDialogShell(
      maxWidth: 760,
      maxHeight: 820,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Nouvelle commande', style: BpTextStyles.heading3),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildClientSelector(clientProvider),
                      const SizedBox(height: 12),
                      _buildProductAdder(productProvider, isCompact, constraints.maxWidth),
                      const SizedBox(height: 12),
                      _buildCartSection(isCompact),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        decoration: BpInputTheme.light(
                          label: 'Notes',
                          prefixIcon: Icons.notes_outlined,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'TOTAL : ${_total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: BpColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _selectedClient != null && _cartItems.isNotEmpty
                        ? _submitOrder
                        : null,
                    child: const Text('Creer la commande'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientSelector(ClientProvider provider) {
    return DropdownButtonFormField<Client>(
      value: _selectedClient,
      decoration: BpInputTheme.light(
        label: 'Selectionner un client',
        prefixIcon: Icons.person_outline,
      ),
      items: provider.clients
          .map((client) => DropdownMenuItem(value: client, child: Text(client.fullName)))
          .toList(),
      onChanged: (value) => setState(() => _selectedClient = value),
    );
  }

  Widget _buildProductAdder(
    ProductProvider provider,
    bool isCompact,
    double availableWidth,
  ) {
    final inputWidth = isCompact ? availableWidth : 380.0;
    final quantityWidth = isCompact ? availableWidth : 120.0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: inputWidth,
          child: DropdownButtonFormField<Product>(
            value: _selectedProduct,
            decoration: BpInputTheme.light(
              label: 'Ajouter un produit',
              prefixIcon: Icons.inventory_2_outlined,
            ),
            items: provider.products
                .map((product) => DropdownMenuItem(value: product, child: Text(product.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedProduct = value),
          ),
        ),
        SizedBox(
          width: quantityWidth,
          child: TextField(
            controller: _quantityController,
            decoration: BpInputTheme.light(
              label: 'Quantite',
              prefixIcon: Icons.onetwothree_outlined,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        SizedBox(
          width: isCompact ? availableWidth : 120,
          child: FilledButton.icon(
            onPressed: _addSelectedProduct,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        ),
      ],
    );
  }

  Widget _buildCartSection(bool isCompact) {
    if (_cartItems.isEmpty) {
      return const Text('Aucun article ajoute.');
    }

    if (isCompact) {
      return Column(
        children: _cartItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BpColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BpColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: BpTextStyles.bodyBold),
                        const SizedBox(height: 4),
                        Text('${item['price']} FCFA', style: BpTextStyles.caption),
                        Text('Qté ${item['quantity']}', style: BpTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: BpColors.error),
                    onPressed: () => setState(() => _cartItems.removeAt(index)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return DataTable(
      headingRowColor: const WidgetStatePropertyAll(BpColors.surfaceMuted),
      columns: const [
        DataColumn(label: Text('Produit')),
        DataColumn(label: Text('Prix')),
        DataColumn(label: Text('Qté')),
        DataColumn(label: Text('Action')),
      ],
      rows: _cartItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return DataRow(
          cells: [
            DataCell(Text(item['name'])),
            DataCell(Text('${item['price']} FCFA')),
            DataCell(Text('${item['quantity']}')),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: BpColors.error),
                onPressed: () => setState(() => _cartItems.removeAt(index)),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _addSelectedProduct() {
    final product = _selectedProduct;
    if (product == null) {
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      _cartItems.add({
        'product': product.id,
        'name': product.name,
        'price': product.sellingPrice,
        'quantity': quantity,
      });
    });
  }

  void _submitOrder() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderData = {
      'client': _selectedClient!.id,
      'items': _cartItems
          .map((item) => {'product': item['product'], 'quantity': item['quantity']})
          .toList(),
      'notes': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    };

    final success = await Provider.of<OrderProvider>(
      context,
      listen: false,
    ).createOrder(orderData, auth.token!);

    if (success) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (mounted) {
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Echec de la creation de la commande.')),
      );
    }
  }
}
