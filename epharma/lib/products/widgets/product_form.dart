import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:epharma/products/pharmacy_products_page.dart';
import 'package:epharma/providers/product_categories.dart';

import '../../models/product_model.dart';
import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_ui.dart';

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
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;
  late final TextEditingController _thresholdController;
  ProductCategory? _selectedCategory;
  late final TextEditingController _lotNumberController;
  late final TextEditingController _lotQtyController;
  DateTime? _lotMfg;
  DateTime? _lotExp;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _descController = TextEditingController(text: product?.description ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _purchaseController = TextEditingController(
      text: product != null ? product.purchasePrice.toString() : '',
    );
    _sellingController = TextEditingController(
      text: product != null ? product.sellingPrice.toString() : '',
    );
    _thresholdController = TextEditingController(
      text: product != null ? product.lowStockThreshold.toString() : '10',
    );
    _selectedCategory = getCategoryByValue(product?.category ?? '');

    if (product != null && product.lots.isNotEmpty) {
      final firstLot = product.lots.first;
      _lotNumberController = TextEditingController(text: firstLot.lotNumber);
      _lotQtyController = TextEditingController(text: firstLot.quantityAvailable.toString());
      _lotMfg = firstLot.manufacturingDate;
      _lotExp = firstLot.expirationDate;
    } else {
      _lotNumberController = TextEditingController();
      _lotQtyController = TextEditingController();
    }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: widget.product?.id ?? 'P${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _selectedCategory?.value ?? _categoryController.text.trim(),
      description: _descController.text.trim(),
      barcode: _barcodeController.text.trim(),
      qrCode: widget.product?.qrCode,
      purchasePrice: double.tryParse(_purchaseController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingController.text) ?? 0,
      lowStockThreshold: int.tryParse(_thresholdController.text) ?? 10,
      lots: _buildInitialLots(),
    );

    Navigator.of(context).pop(product);
  }

  List<Lot> _buildInitialLots() {
    final newLotNumber = _lotNumberController.text.trim();
    final newQty = int.tryParse(_lotQtyController.text) ?? 0;
    final manufacturingDate = _lotMfg ?? DateTime.now();
    final expirationDate = _lotExp ?? DateTime.now().add(const Duration(days: 365));

    if (widget.product != null) {
      if (newLotNumber.isNotEmpty) {
        final updatedLot = Lot(
          lotNumber: newLotNumber,
          manufacturingDate: manufacturingDate,
          expirationDate: expirationDate,
          quantity: newQty,
          quantityAvailable: newQty,
          costPrice: double.tryParse(_purchaseController.text) ?? 0.0,
        );
        if (widget.product!.lots.isNotEmpty) {
          return [updatedLot, ...widget.product!.lots.skip(1)];
        }
        return [updatedLot];
      }
      return widget.product!.lots;
    }

    if (newLotNumber.isNotEmpty) {
      return [
        Lot(
          lotNumber: newLotNumber,
          manufacturingDate: manufacturingDate,
          expirationDate: expirationDate,
          quantity: newQty,
          quantityAvailable: newQty,
          costPrice: double.tryParse(_purchaseController.text) ?? 0.0,
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      maxWidth: 760,
      maxHeight: 880,
      child: Form(
        key: _formKey,
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
                      child: Text(
                        widget.product == null ? 'Ajouter un produit' : 'Modifier le produit',
                        style: BpTextStyles.heading3,
                      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: BpInputTheme.light(
                            label: 'Nom du produit',
                            prefixIcon: Icons.medication_outlined,
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ProductCategory>(
                          value: _selectedCategory,
                          decoration: BpInputTheme.light(
                            label: 'Categorie',
                            prefixIcon: Icons.category_outlined,
                          ),
                          items: productCategories
                              .map(
                                (category) => DropdownMenuItem<ProductCategory>(
                                  value: category,
                                  child: Text(category.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _categoryController.text = value?.value ?? '';
                            });
                          },
                          validator: (value) => value == null ? 'Obligatoire' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          decoration: BpInputTheme.light(
                            label: 'Description',
                            prefixIcon: Icons.notes_outlined,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _barcodeController,
                          decoration: BpInputTheme.light(
                            label: 'Code-barres',
                            prefixIcon: Icons.qr_code_2_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        if (isCompact)
                          Column(
                            children: [
                              _buildMoneyField(
                                controller: _purchaseController,
                                label: 'Prix d\'achat',
                              ),
                              const SizedBox(height: 12),
                              _buildMoneyField(
                                controller: _sellingController,
                                label: 'Prix de vente',
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _buildMoneyField(
                                  controller: _purchaseController,
                                  label: 'Prix d\'achat',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMoneyField(
                                  controller: _sellingController,
                                  label: 'Prix de vente',
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _thresholdController,
                          decoration: BpInputTheme.light(
                            label: 'Seuil de stock bas',
                            prefixIcon: Icons.warning_amber_outlined,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) => int.tryParse(value ?? '') == null ? 'Nombre invalide' : null,
                        ),
                        const SizedBox(height: 12),
                        if (isCompact)
                          Column(
                            children: [
                              _buildLotField(controller: _lotNumberController, label: 'Numero de lot'),
                              const SizedBox(height: 12),
                              _buildLotField(controller: _lotQtyController, label: 'Quantite'),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _buildLotField(
                                  controller: _lotNumberController,
                                  label: 'Numero de lot',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLotField(
                                  controller: _lotQtyController,
                                  label: 'Quantite',
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        if (isCompact)
                          Column(
                            children: [
                              _buildDateButton(
                                label: _lotMfg == null
                                    ? 'Date de reception: N/A'
                                    : 'Recu: ${formatDate(_lotMfg!)}',
                                buttonLabel: 'Date reception',
                                icon: Icons.event_available_outlined,
                                onPick: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _lotMfg = date);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDateButton(
                                label: _lotExp == null
                                    ? 'Date d\'expiration: N/A'
                                    : 'Expire: ${formatDate(_lotExp!)}',
                                buttonLabel: 'Date expiration',
                                icon: Icons.event_busy_outlined,
                                onPick: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 365)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                                  );
                                  if (date != null) {
                                    setState(() => _lotExp = date);
                                  }
                                },
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateButton(
                                  label: _lotMfg == null
                                      ? 'Date de reception: N/A'
                                      : 'Recu: ${formatDate(_lotMfg!)}',
                                  buttonLabel: 'Date reception',
                                  icon: Icons.event_available_outlined,
                                  onPick: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _lotMfg = date);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateButton(
                                  label: _lotExp == null
                                      ? 'Date d\'expiration: N/A'
                                      : 'Expire: ${formatDate(_lotExp!)}',
                                  buttonLabel: 'Date expiration',
                                  icon: Icons.event_busy_outlined,
                                  onPick: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().add(const Duration(days: 365)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                                    );
                                    if (date != null) {
                                      setState(() => _lotExp = date);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoneyField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: BpInputTheme.light(
        label: label,
        prefixIcon: Icons.payments_outlined,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => double.tryParse(value ?? '') == null ? 'Nombre invalide' : null,
    );
  }

  Widget _buildLotField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: BpInputTheme.light(
        label: label,
        prefixIcon: Icons.inventory_2_outlined,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildDateButton({
    required String label,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BpTextStyles.caption),
        const SizedBox(height: 6),
        FilledButton.tonalIcon(
          onPressed: onPick,
          icon: Icon(icon, size: 18),
          label: Text(buttonLabel),
        ),
      ],
    );
  }
}
