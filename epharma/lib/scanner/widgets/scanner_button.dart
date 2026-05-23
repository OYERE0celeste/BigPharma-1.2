import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dialogs/scanner_dialog.dart';
import '../providers/scanner_provider.dart';
import '../../models/product_model.dart';

typedef OnProductScanned = void Function(Product product);

/// 🔘 Reusable scanner button widget
///
/// Usage:
/// ```dart
/// ScannerButton(
///   onProductScanned: (product) {
///     // Handle product
///   },
/// )
/// ```
class ScannerButton extends StatelessWidget {
  /// Callback when product successfully scanned
  final OnProductScanned? onProductScanned;

  /// Callback when scan cancelled
  final VoidCallback? onCancelled;

  /// Button style (icon, filled, outlined)
  final ScannerButtonStyle style;

  /// Button size
  final double iconSize;

  /// Custom tooltip
  final String? tooltip;

  /// If true, shows loading indicator
  final bool isLoading;

  const ScannerButton({
    super.key,
    this.onProductScanned,
    this.onCancelled,
    this.style = ScannerButtonStyle.icon,
    this.iconSize = 24,
    this.tooltip,
    this.isLoading = false,
  });

  Future<void> _openScanner(BuildContext context) async {
    if (isLoading) return;

    try {
      final result = await showDialog<Product>(
        context: context,
        builder: (context) => const ScannerDialog(),
        barrierDismissible: false,
      );

      if (result != null) {
        onProductScanned?.call(result);
      } else {
        onCancelled?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerProvider>(
      builder: (context, scannerProvider, _) {
        return switch (style) {
          ScannerButtonStyle.icon => _buildIconButton(context),
          ScannerButtonStyle.fab => _buildFAB(context),
          ScannerButtonStyle.filled => _buildFilledButton(context),
          ScannerButtonStyle.outlined => _buildOutlinedButton(context),
        };
      },
    );
  }

  Widget _buildIconButton(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'Scanner QR/Code-Barres',
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.qr_code_scanner, size: iconSize),
        onPressed: isLoading ? null : () => _openScanner(context),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : () => _openScanner(context),
      backgroundColor: Colors.green,
      tooltip: tooltip ?? 'Scanner',
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.qr_code_scanner, size: iconSize),
    );
  }

  Widget _buildFilledButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : () => _openScanner(context),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.qr_code_scanner, size: iconSize),
      label: const Text('Scanner'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () => _openScanner(context),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.qr_code_scanner, size: iconSize),
      label: const Text('Scanner'),
    );
  }
}

/// Button style variants
enum ScannerButtonStyle {
  icon, // Just icon
  fab, // Floating Action Button
  filled, // Filled button with text
  outlined, // Outlined button with text
}
