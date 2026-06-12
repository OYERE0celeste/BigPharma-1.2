import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'bp_theme.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  static Future<Product?> show(BuildContext context) async {
    return showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BarcodeScannerDialog(),
    );
  }

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  final ProductService _productService = ProductService();
  final TextEditingController _manualInputController = TextEditingController();
  final FocusNode _manualInputFocus = FocusNode();

  bool _isFlashOn = false;
  bool _showManualInput = false;
  bool _isLoading = false;
  bool _isCooldown = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    _manualInputController.dispose();
    _manualInputFocus.dispose();
    super.dispose();
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isLoading || _isCooldown) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.lightImpact();

    final product = await _productService.getProductByCode(code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (product != null) {
      Navigator.pop(context, product);
    } else {
      setState(() {
        _errorMessage = "Produit non trouvé";
        _isCooldown = true;
      });

      // Cooldown of 2.5 seconds to let the user move away before scanning again
      Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _isCooldown = false;
            _errorMessage = null;
          });
        }
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isLoading || _isCooldown) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _handleScannedCode(rawValue);
        break; // Process the first valid scan
      }
    }
  }

  void _submitManualInput() {
    final code = _manualInputController.text.trim();
    if (code.isNotEmpty) {
      _handleScannedCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Scanner un produit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: () async {
                await _scannerController.toggleTorch();
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard,
                color: _showManualInput ? primaryColor : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showManualInput = !_showManualInput;
                });
                if (_showManualInput) {
                  _manualInputFocus.requestFocus();
                } else {
                  _manualInputFocus.unfocus();
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // 1. Scanner Camera View
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),

            // 2. Custom Scanner Overlay Frame
            _buildScannerOverlay(primaryColor),

            // 3. Status messages/cooldown alerts
            _buildStatusOverlay(),

            // 4. Manual Input Field
            if (_showManualInput) _buildManualInputWidget(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Color themeColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double scanAreaSize = width * 0.70 < 280.0 ? width * 0.70 : 280.0;
        final double left = (width - scanAreaSize) / 2;
        final double top = (height - scanAreaSize) / 2 - 40; // Slightly higher center

        return Stack(
          children: [
            // Dark Semi-transparent Mask around scan area
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    width: scanAreaSize,
                    height: scanAreaSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scan Window Target Box with Glowing Corners
            Positioned(
              left: left,
              top: top,
              width: scanAreaSize,
              height: scanAreaSize,
              child: Stack(
                children: [
                  // Corner brackets
                  _buildCorner(0, 0, top: true, left: true, color: themeColor),
                  _buildCorner(scanAreaSize, 0, top: true, left: false, color: themeColor),
                  _buildCorner(0, scanAreaSize, top: false, left: true, color: themeColor),
                  _buildCorner(scanAreaSize, scanAreaSize, top: false, left: false, color: themeColor),

                  // Moving scanning red/green line
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      final double lineTop = _scanLineAnimation.value * (scanAreaSize - 20) + 10;
                      return Positioned(
                        top: lineTop,
                        left: 15,
                        right: 15,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeColor.withOpacity(0.1),
                                themeColor,
                                themeColor.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Instruction Text Below the box
            Positioned(
              left: 20,
              right: 20,
              top: top + scanAreaSize + 28,
              child: const Text(
                'Cadrez le code-barres ou le code QR\npour lancer la recherche',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(double x, double y, {required bool top, required bool left, required Color color}) {
    const double length = 24.0;
    const double thickness = 4.0;
    const double radiusOffset = 2.0;

    return Positioned(
      left: left ? x - radiusOffset : x - length + radiusOffset,
      top: top ? y - radiusOffset : y - length + radiusOffset,
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left, color: color, thickness: thickness),
      ),
    );
  }

  Widget _buildStatusOverlay() {
    if (_isLoading) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: BpColors.accent),
              SizedBox(height: 16),
              Text(
                'Analyse du produit en cours...',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BpColors.error, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: BpColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildManualInputWidget(Color themeColor) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BpColors.surfaceStrong.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BpColors.borderStrong),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _manualInputController,
                focusNode: _manualInputFocus,
                onSubmitted: (_) => _submitManualInput(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Entrez le code-barres...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _submitManualInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.top,
    required this.left,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (top && left) {
      path.moveTo(size.width, thickness / 2);
      path.lineTo(thickness / 2, thickness / 2);
      path.lineTo(thickness / 2, size.height);
    } else if (top && !left) {
      path.moveTo(0, thickness / 2);
      path.lineTo(size.width - thickness / 2, thickness / 2);
      path.lineTo(size.width - thickness / 2, size.height);
    } else if (!top && left) {
      path.moveTo(size.width, size.height - thickness / 2);
      path.lineTo(thickness / 2, size.height - thickness / 2);
      path.lineTo(thickness / 2, 0);
    } else if (!top && !left) {
      path.moveTo(0, size.height - thickness / 2);
      path.lineTo(size.width - thickness / 2, size.height - thickness / 2);
      path.lineTo(size.width - thickness / 2, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
