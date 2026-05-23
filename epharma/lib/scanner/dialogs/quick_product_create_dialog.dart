import 'package:flutter/material.dart';
import '../services/product_lookup_service.dart';

/// ➕ Quick product creation dialog when barcode not found
class QuickProductCreateDialog extends StatefulWidget {
  /// Pre-filled barcode from scan
  final String? scannedCode;

  /// Pre-filled QR code if from QR scan
  final String? scannedQRCode;

  /// Categories for selection
  final List<String> categories;

  /// Data retrieved from internet lookup
  final ProductLookupResult? lookupData;

  /// Callback with created product data
  final Function(Map<String, dynamic> productData) onCreate;

  const QuickProductCreateDialog({
    super.key,
    this.scannedCode,
    this.scannedQRCode,
    this.lookupData,
    required this.categories,
    required this.onCreate,
  });

  @override
  State<QuickProductCreateDialog> createState() =>
      _QuickProductCreateDialogState();
}

class _QuickProductCreateDialogState extends State<QuickProductCreateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _barcodeController;
  late TextEditingController _qrCodeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;

  String _selectedCategory = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.lookupData?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.lookupData?.description ?? '',
    );
    _barcodeController = TextEditingController(text: widget.scannedCode ?? '');
    _qrCodeController = TextEditingController(text: widget.scannedQRCode ?? '');
    _purchasePriceController = TextEditingController();
    _sellingPriceController = TextEditingController();

    _selectedCategory =
        widget.lookupData?.category != null &&
            widget.categories.contains(widget.lookupData!.category)
        ? widget.lookupData!.category!
        : widget.categories.isNotEmpty
        ? widget.categories.first
        : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _qrCodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      _showError('Le nom du produit est requis');
      return false;
    }

    if (_barcodeController.text.isEmpty && _qrCodeController.text.isEmpty) {
      _showError('Au moins un code (barcode ou QR) est requis');
      return false;
    }

    final purchasePrice = double.tryParse(_purchasePriceController.text);
    final sellingPrice = double.tryParse(_sellingPriceController.text);

    if (purchasePrice == null || purchasePrice < 0) {
      _showError('Prix d\'achat invalide');
      return false;
    }

    if (sellingPrice == null || sellingPrice < purchasePrice) {
      _showError('Prix de vente invalide (doit être ≥ prix d\'achat)');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleCreate() {
    if (!_validateForm()) return;

    final productData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'description': _descriptionController.text.trim(),
      'barcode': _barcodeController.text.trim(),
      'qrCode': _qrCodeController.text.trim(),
      'purchasePrice': double.parse(_purchasePriceController.text),
      'sellingPrice': double.parse(_sellingPriceController.text),
      'lowStockThreshold': 10,
      'lots': [],
    };

    setState(() => _isLoading = true);

    // Call callback with product data
    widget.onCreate(productData);

    // Close dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, productData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un nouveau produit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remplissez les informations rapidement',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom du produit *',
                hintText: 'Ex: Paracétamol 500mg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.medication),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              decoration: InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: widget.categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Description du produit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Code-barres',
                hintText: 'Scanned barcode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.barcode_reader),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),

            // QR Code
            TextFormField(
              controller: _qrCodeController,
              decoration: InputDecoration(
                labelText: 'Code QR',
                hintText: 'Scanned QR code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.qr_code),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),

            // Prices row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceController,
                    decoration: InputDecoration(
                      labelText: 'Prix d\'achat *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    decoration: InputDecoration(
                      labelText: 'Prix de vente *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.sell),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }
}
