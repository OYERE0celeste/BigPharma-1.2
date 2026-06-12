// 🔍 Product Not Found Dialog
//
// Shown when a scanned barcode doesn't match any product in database.
//
// Responsibilities:
// - Display barcode that was scanned
// - Show "Product not found" message
// - Offer "Create Product" option (for inventory management)
// - Allow user to dismiss and continue scanning
//
// Usage:
// ```dart
// showDialog(
//   context: context,
//   builder: (_) => ProductNotFoundDialog(
//     barcode: "1234567890123",
//     onCreateProduct: () => navigateToCreateProduct("1234567890123"),
//   ),
// );
// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/bp_theme.dart';

/// 🔍 Dialog for handling scanned barcode not found in database
class ProductNotFoundDialog extends StatefulWidget {
  /// The barcode that was scanned but not found
  final String barcode;

  /// Callback when user taps "Create Product"
  final VoidCallback? onCreateProduct;

  /// Callback when user taps "Continue Scanning"
  final VoidCallback? onContinueScanning;

  /// Optional subtitle message
  final String? subtitle;

  /// Custom title (default: "Produit non trouvé")
  final String? title;

  const ProductNotFoundDialog({
    super.key,
    required this.barcode,
    this.onCreateProduct,
    this.onContinueScanning,
    this.subtitle,
    this.title,
  });

  @override
  State<ProductNotFoundDialog> createState() => _ProductNotFoundDialogState();
}

class _ProductNotFoundDialogState extends State<ProductNotFoundDialog> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BpColors.scaffold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.search_off, color: BpColors.warning, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title ?? 'Produit non trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BpColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== BARCODE DISPLAY ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BpColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BpColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barcode scanné:',
                    style: TextStyle(
                      fontSize: 12,
                      color: BpColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.barcode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BpColors.textPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Copy button
                      GestureDetector(
                        onTap: _copyBarcodeToClipboard,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: BpColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _isCopied ? Icons.check : Icons.content_copy,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // ========== ERROR MESSAGE ==========
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BpColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: BpColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ce barcode n\'existe pas dans la base de données.',
                    style: TextStyle(
                      fontSize: 14,
                      color: BpColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: BpColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 16),

            // ========== OPTIONS ==========
            Text(
              'Options:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: BpColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Créer un nouveau produit avec ce barcode\n'
              '• Continuer le scan avec un autre barcode\n'
              '• Vérifier le barcode et rescanner',
              style: TextStyle(
                fontSize: 12,
                color: BpColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ========== CONTINUE BUTTON ==========
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onContinueScanning?.call();
          },
          child: Text(
            'Continuer le scan',
            style: TextStyle(color: BpColors.textSecondary),
          ),
        ),

        const SizedBox(width: 8),

        // ========== CREATE PRODUCT BUTTON ==========
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCreateProduct?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BpColors.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Text('Créer produit'),
            ],
          ),
        ),
      ],
    );
  }

  /// Copy barcode to clipboard
  void _copyBarcodeToClipboard() {
    // Copy to clipboard
    final scaffold = ScaffoldMessenger.of(context);

    Clipboard.setData(ClipboardData(text: widget.barcode));

    // Show feedback
    setState(() => _isCopied = true);

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });

    // Show snackbar
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Barcode copié'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BpColors.success,
      ),
    );
  }
}

// ============================================================================
// HELPER FUNCTION
// ============================================================================

/// Show ProductNotFoundDialog helper
///
/// Usage:
/// ```dart
/// showProductNotFoundDialog(
///   context: context,
///   barcode: "1234567890123",
///   onCreateProduct: () => print('Create product'),
/// );
/// ```
Future<void> showProductNotFoundDialog({
  required BuildContext context,
  required String barcode,
  VoidCallback? onCreateProduct,
  VoidCallback? onContinueScanning,
  String? subtitle,
  String? title,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ProductNotFoundDialog(
        barcode: barcode,
        onCreateProduct: onCreateProduct,
        onContinueScanning: onContinueScanning,
        subtitle: subtitle,
        title: title,
      );
    },
  );
}

// ============================================================================
// VARIATIONS
// ============================================================================

/// Minimal product not found dialog (smaller version)
class ProductNotFoundDialogMinimal extends StatelessWidget {
  final String barcode;
  final VoidCallback? onDismiss;

  const ProductNotFoundDialogMinimal({
    super.key,
    required this.barcode,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BpColors.scaffold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: BpColors.error),
          SizedBox(width: 8),
          Text(
            'Produit non trouvé',
            style: TextStyle(color: BpColors.textPrimary),
          ),
        ],
      ),
      content: Text(
        'Le barcode "$barcode" n\'a pas été trouvé.',
        style: TextStyle(color: BpColors.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Product not found with retry suggestion
class ProductNotFoundDialogWithRetry extends StatefulWidget {
  final String barcode;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const ProductNotFoundDialogWithRetry({
    super.key,
    required this.barcode,
    this.onRetry,
    this.onCancel,
  });

  @override
  State<ProductNotFoundDialogWithRetry> createState() =>
      _ProductNotFoundDialogWithRetryState();
}

class _ProductNotFoundDialogWithRetryState
    extends State<ProductNotFoundDialogWithRetry> {
  int _retryCount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BpColors.scaffold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Produit non trouvé - Recommencer?',
        style: TextStyle(color: BpColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Barcode: ${widget.barcode}',
            style: TextStyle(
              fontFamily: 'monospace',
              color: BpColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Le produit n\'a pas été trouvé.\n'
            'Vérifiez le barcode et recommencez.',
            textAlign: TextAlign.center,
            style: TextStyle(color: BpColors.textSecondary),
          ),
          if (_retryCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tentative $_retryCount',
                style: TextStyle(color: BpColors.warning, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel?.call();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => _retryCount++);
            Navigator.of(context).pop();
            widget.onRetry?.call();
          },
          style: ElevatedButton.styleFrom(backgroundColor: BpColors.primary),
          child: const Text('Recommencer'),
        ),
      ],
    );
  }
}
