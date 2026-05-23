import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../products/services/product_api_service.dart';
import '../../products/widgets/product_form.dart';
import '../../providers/product_categories.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_notification.dart';
import '../providers/scanner_provider.dart';
import '../services/product_lookup_service.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scanner_overlay.dart';
import 'quick_product_create_dialog.dart';

typedef OnProductScanned = void Function(Product product);
typedef OnProductNotFound = void Function(String code);

class ScannerDialog extends StatefulWidget {
  final OnProductScanned? onProductFound;
  final OnProductNotFound? onProductNotFound;
  final CameraFacing facing;
  final String? title;
  final bool allowManualInput;

  const ScannerDialog({
    super.key,
    this.onProductFound,
    this.onProductNotFound,
    this.facing = CameraFacing.back,
    this.title,
    this.allowManualInput = true,
  });

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> {
  late final ScannerProvider _scannerProvider;
  late final FocusNode _manualInputFocus;
  late final TextEditingController _manualInputController;
  bool _showManualInput = false;
  bool _isClosing = false;
  
  String _hardwareBarcodeBuffer = '';
  Timer? _hardwareBarcodeTimer;
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scannerProvider = context.read<ScannerProvider>();
    _manualInputFocus = FocusNode();
    _manualInputController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScanner();
    });
  }

  @override
  void dispose() {
    if (!_isClosing) {
      _scannerProvider.shutdownScanner(notify: false);
    }
    _hardwareBarcodeTimer?.cancel();
    _keyboardFocusNode.dispose();
    _manualInputFocus.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    if (_scannerProvider.isInitialized || _scannerProvider.isActive) {
      await _scannerProvider.shutdownScanner(notify: false);
    }

    final initialized = await _scannerProvider.initializeScanner(
      onScan: _handleResolvedProduct,
      onError: _showErrorSnackbar,
    );

    if (!initialized || !mounted || _isClosing) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isClosing) {
        return;
      }
      await _scannerProvider.startScanning();
    });
  }

  void _handleResolvedProduct() {
    final product = _scannerProvider.lastProduct;
    if (product != null) {
      widget.onProductFound?.call(product);
    }
  }

  Future<void> _closeScanner([Product? result]) async {
    if (_isClosing || !mounted) {
      return;
    }

    _isClosing = true;
    await _scannerProvider.shutdownScanner();

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _startCreateFlow({
    String? barcode,
    String? qrCode,
    ProductLookupResult? lookupData,
  }) async {
    final scannedCode =
        barcode ?? lookupData?.barcode ?? _scannerProvider.lastScan?.rawValue;
    final scannedQrCode = qrCode ?? _scannerProvider.lastScan?.rawValue;

    final productData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => QuickProductCreateDialog(
        scannedCode: scannedCode,
        scannedQRCode: scannedQrCode,
        categories: productCategories.map((e) => e.value).toList(),
        lookupData: lookupData,
        onCreate: (_) {},
      ),
    );

    if (productData == null || !mounted) {
      return;
    }

    try {
      final product = Product.fromJson(productData);
      final created = await ProductApiService.createProduct(product);

      if (!mounted) {
        return;
      }

      _showResultSnackbar('Produit cree : ${created.name}');
      widget.onProductFound?.call(created);
      await _closeScanner(created);
    } catch (e) {
      _showErrorSnackbar('Erreur creation produit : $e');
    }
  }

  void _showResultSnackbar(String message) {
    if (!mounted) {
      return;
    }

    AppScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) {
      return;
    }

    AppScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleManualInput(String code) async {
    if (code.isEmpty) {
      return;
    }

    _showResultSnackbar('Recherche du produit...');

    final product = await _scannerProvider.searchByBarcode(code);

    if (!mounted) {
      return;
    }

    if (product != null) {
      widget.onProductFound?.call(product);
      _showResultSnackbar('Produit trouve');
    } else if (_scannerProvider.state == ScannerState.lookupFound) {
      _showResultSnackbar('Informations produit recuperees en ligne');
    } else {
      widget.onProductNotFound?.call(code);
      _showErrorSnackbar('Produit non trouve');
    }

    if (_showManualInput) {
      _manualInputController.clear();
      _manualInputFocus.requestFocus();
    }
  }

  Future<void> _toggleTorch() async {
    await _scannerProvider.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _closeScanner();
        return false;
      },
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (_hardwareBarcodeBuffer.isNotEmpty) {
                _handleManualInput(_hardwareBarcodeBuffer);
                _hardwareBarcodeBuffer = '';
              }
            } else if (event.character != null && event.character!.isNotEmpty) {
              _hardwareBarcodeBuffer += event.character!;
              _hardwareBarcodeTimer?.cancel();
              _hardwareBarcodeTimer = Timer(const Duration(milliseconds: 200), () {
                _hardwareBarcodeBuffer = '';
              });
            }
          }
        },
        child: Dialog.fullscreen(
        child: Consumer<ScannerProvider>(
          builder: (context, scannerProvider, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title ?? 'Scanner QR / Code-barres',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeScanner,
                ),
                actions: [
                  FutureBuilder<bool>(
                    future: scannerProvider.scannerService.hasTorch(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return IconButton(
                          icon: const Icon(Icons.flashlight_on),
                          onPressed: _toggleTorch,
                          tooltip: 'Lampe torche',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  if (widget.allowManualInput)
                    IconButton(
                      icon: const Icon(Icons.keyboard),
                      onPressed: () {
                        setState(() => _showManualInput = !_showManualInput);
                        if (_showManualInput) {
                          _manualInputFocus.requestFocus();
                        }
                      },
                      tooltip: 'Entree manuelle',
                    ),
                ],
              ),
              body: Stack(
                children: [
                  if (scannerProvider.isInitialized &&
                      scannerProvider.scannerService.controller != null)
                    MobileScanner(
                      controller: scannerProvider.scannerService.controller!,
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Initialisation du scanner...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  if (scannerProvider.isActive)
                    ScannerOverlay(
                      controller:
                          scannerProvider.scannerService.controller ??
                          MobileScannerController(),
                      onScan: (_) {},
                      isActive: true,
                      message: scannerProvider.isLoading
                          ? 'Recherche en cours...'
                          : 'Cadrez le code pour scanner',
                    ),
                  if (scannerProvider.state == ScannerState.found &&
                      scannerProvider.lastProduct != null)
                    _buildResultOverlay(context, scannerProvider.lastProduct!),
                  if (scannerProvider.state == ScannerState.lookupFound &&
                      scannerProvider.lookupResult != null)
                    _buildLookupOverlay(context, scannerProvider.lookupResult!),
                  if (scannerProvider.state == ScannerState.notFound)
                    _buildNotFoundOverlay(context, scannerProvider),
                  if (_showManualInput)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: _buildManualInputField(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildResultOverlay(BuildContext context, Product product) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ScanResultCard(
        product: product,
        showActions: true,
        onAddToCart: () => _closeScanner(product),
        onViewDetails: () {},
        onEditProduct: () async {
          final updated = await showDialog<Product>(
            context: context,
            builder: (_) => ProductFormDialog(product: product),
          );

          if (updated == null || !mounted) {
            return;
          }

          try {
            await context.read<ProductProvider>().updateProduct(updated);
            context.read<ScannerProvider>().clearLastScan();
            widget.onProductFound?.call(updated);
            _showResultSnackbar('Produit mis a jour');
          } catch (e) {
            _showErrorSnackbar('Erreur mise a jour produit : $e');
          }
        },
      ),
    );
  }

  Widget _buildLookupOverlay(
    BuildContext context,
    ProductLookupResult lookupResult,
  ) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informations produit recuperees en ligne',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lookupResult.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lookupResult.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            if (lookupResult.imageUrl != null) const SizedBox(height: 12),
            Text(
              lookupResult.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (lookupResult.brand != null) ...[
              const SizedBox(height: 6),
              Text('Marque: ${lookupResult.brand}'),
            ],
            if (lookupResult.category != null) ...[
              const SizedBox(height: 6),
              Text('Categorie: ${lookupResult.category}'),
            ],
            if (lookupResult.description != null) ...[
              const SizedBox(height: 6),
              Text(
                lookupResult.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _startCreateFlow(
                        barcode: lookupResult.barcode,
                        qrCode: _scannerProvider.lastScan?.rawValue,
                        lookupData: lookupResult,
                      );
                    },
                    child: const Text('Creer le produit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _closeScanner,
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundOverlay(
    BuildContext context,
    ScannerProvider scannerProvider,
  ) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300, width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Produit non trouve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: scannerProvider.clearLastScan,
                    child: const Text('Reessayer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _closeScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _manualInputController,
            focusNode: _manualInputFocus,
            onSubmitted: _handleManualInput,
            decoration: InputDecoration(
              hintText: 'Entrez le code-barres...',
              prefixIcon: const Icon(Icons.barcode_reader),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () =>
                    _handleManualInput(_manualInputController.text.trim()),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur Entree pour rechercher',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
