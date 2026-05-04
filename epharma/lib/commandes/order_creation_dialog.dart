import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/client_provider.dart';
import '../providers/product_provider.dart';
import '../models/client_model.dart';
import '../models/product_model.dart';

class OrderCreationDialog extends StatefulWidget {
  const OrderCreationDialog({super.key});

  @override
  State<OrderCreationDialog> createState() => _OrderCreationDialogState();
}

class _OrderCreationDialogState extends State<OrderCreationDialog> {
  Client? _selectedClient;
  final List<Map<String, dynamic>> _cartItems = [];
  String? _note;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  double get _total => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return AlertDialog(
      title: const Text('Nouvelle Commande'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildClientSelector(clientProvider),
              const SizedBox(height: 16),
              _buildProductAdder(productProvider),
              const SizedBox(height: 16),
              _buildCartTable(),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                onChanged: (val) => _note = val,
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text('TOTAL : ${_total.toStringAsFixed(0)} FCFA', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _selectedClient != null && _cartItems.isNotEmpty ? () => _submitOrder() : null,
          child: const Text('Créer la commande'),
        ),
      ],
    );
  }

  Widget _buildClientSelector(ClientProvider provider) {
    return DropdownButtonFormField<Client>(
      decoration: const InputDecoration(labelText: 'Sélectionner un Client', border: OutlineInputBorder()),
      items: provider.clients.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
      onChanged: (val) => setState(() => _selectedClient = val),
    );
  }

  Widget _buildProductAdder(ProductProvider provider) {
    Product? selectedProduct;
    int quantity = 1;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<Product>(
            decoration: const InputDecoration(labelText: 'Ajouter un Produit', border: OutlineInputBorder()),
            items: provider.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
            onChanged: (val) => selectedProduct = val,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Qté', border: OutlineInputBorder()),
            initialValue: '1',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) => quantity = int.tryParse(val) ?? 1,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 32),
          onPressed: () {
            if (selectedProduct != null) {
              setState(() {
                _cartItems.add({
                  'product': selectedProduct!.id,
                  'name': selectedProduct!.name,
                  'price': selectedProduct!.sellingPrice,
                  'quantity': quantity,
                });
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCartTable() {
    if (_cartItems.isEmpty) return const Text('Aucun article ajouté.');

    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      children: [
        const TableRow(children: [
          Padding(padding: EdgeInsets.all(8), child: Text('Produit', style: TextStyle(fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8), child: Text('Prix', style: TextStyle(fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8), child: Text('Qté', style: TextStyle(fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8), child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
        ]),
        ..._cartItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return TableRow(children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(item['name'])),
            Padding(padding: const EdgeInsets.all(8), child: Text('${item['price']} FCFA')),
            Padding(padding: const EdgeInsets.all(8), child: Text('${item['quantity']}')),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _cartItems.removeAt(idx))),
          ]);
        }),
      ],
    );
  }

  void _submitOrder() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderData = {
      'client': _selectedClient!.id,
      'items': _cartItems.map((i) => {
        'product': i['product'],
        'quantity': i['quantity'],
      }).toList(),
      'notes': _note,
    };

    final success = await Provider.of<OrderProvider>(context, listen: false).createOrder(orderData, auth.token!);
    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Échec de la création de la commande.")));
      }
    }
  }
}
