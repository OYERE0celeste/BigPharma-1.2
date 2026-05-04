import 'package:epharma/products/pharmacy_products_page.dart';
import 'package:epharma/providers/product_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descController;
  late final TextEditingController _barcodeController;
  bool _prescription = false;
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;
  late final TextEditingController _thresholdController;
  ProductCategory? _selectedCategory;
  // initial lot
  late final TextEditingController _lotNumberController;
  late final TextEditingController _lotQtyController;
  DateTime? _lotExp;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _prescription = p?.prescriptionRequired ?? false;
    _purchaseController = TextEditingController(
      text: p != null ? p.purchasePrice.toString() : '',
    );
    _sellingController = TextEditingController(
      text: p != null ? p.sellingPrice.toString() : '',
    );
    _thresholdController = TextEditingController(
      text: p != null ? p.lowStockThreshold.toString() : '10',
    );
    _selectedCategory = getCategoryByValue(p?.category ?? '');
    _lotNumberController = TextEditingController();
    _lotQtyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _barcodeController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _thresholdController.dispose();
    _lotNumberController.dispose();
    _lotQtyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final p = Product(
      id: widget.product?.id ?? 'P${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _selectedCategory?.value ?? _categoryController.text.trim(),
      description: _descController.text.trim(),
      barcode: _barcodeController.text.trim(),
      prescriptionRequired: _prescription,
      purchasePrice: double.tryParse(_purchaseController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingController.text) ?? 0,
      lowStockThreshold: int.tryParse(_thresholdController.text) ?? 10,
      lots: _buildInitialLots(),
    );

    Navigator.of(context).pop(p);
  }

  List<Lot> _buildInitialLots() {
    if (_lotNumberController.text.isEmpty) return widget.product?.lots ?? [];
    final qty = int.tryParse(_lotQtyController.text) ?? 0;
    final exp = _lotExp ?? DateTime.now().add(const Duration(days: 365));
    return [
      Lot(
        lotNumber: _lotNumberController.text.trim(),
        manufacturingDate: DateTime.now(),
        expirationDate: exp,
        quantity: qty,
        quantityAvailable: qty,
        costPrice: double.tryParse(_purchaseController.text) ?? 0.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product == null
                            ? 'Ajouter un produit'
                            : 'Modifier le produit',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProductCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                    items: productCategories.map((category) {
                      return DropdownMenuItem<ProductCategory>(
                        value: category,
                        child: Text(category.label),
                      );
                    }).toList(),
                    onChanged: (ProductCategory? value) {
                      setState(() {
                        _selectedCategory = value;
                        _categoryController.text = value?.value ?? '';
                      });
                    },
                    validator: (value) => value == null ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Prescription requise'),
                    value: _prescription,
                    onChanged: (v) => setState(() => _prescription = v),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _purchaseController,
                          decoration: const InputDecoration(
                            labelText: 'Prix d\'achat',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'Number invalide'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _sellingController,
                          decoration: const InputDecoration(
                            labelText: 'Prix de vente',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => (double.tryParse(v ?? '') == null)
                              ? 'Number invalide'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Seuil de stock bas',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => (int.tryParse(v ?? '') == null)
                        ? 'Number invalide'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lotNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Numero de lot',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lotQtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _lotExp == null
                            ? 'Pas d\'expiration selectionnée'
                            : 'Exp: ${formatDate(_lotExp!)}',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (d != null) setState(() => _lotExp = d);
                        },
                        child: const Text('Selectionner une expiration'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
