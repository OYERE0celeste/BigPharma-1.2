import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scan_result_model.dart';

/// 📹 Scanner overlay with animated corners and focus indicator
class ScannerOverlay extends StatefulWidget {
  /// Camera controller from mobile_scanner
  final MobileScannerController controller;

  /// Callback when scan detected
  final Function(ScanResult) onScan;

  /// Whether scanning is active
  final bool isActive;

  /// Custom message to display
  final String? message;

  /// Overlay color opacity (0-1)
  final double overlayOpacity;

  const ScannerOverlay({
    super.key,
    required this.controller,
    required this.onScan,
    this.isActive = true,
    this.message,
    this.overlayOpacity = 0.3,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.75;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dimmed background
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(widget.overlayOpacity),
            BlendMode.darken,
          ),
          child: Container(),
        ),

        // Clear scan area
        Positioned(
          top: (size.height - scanAreaSize) / 2,
          left: (size.width - scanAreaSize) / 2,
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
            ),
          ),
        ),

        // Animated corners
        _buildCorner(
          top: (size.height - scanAreaSize) / 2,
          left: (size.width - scanAreaSize) / 2,
          isTopLeft: true,
        ),
        _buildCorner(
          top: (size.height - scanAreaSize) / 2,
          right: (size.width - scanAreaSize) / 2,
          isTopLeft: false,
        ),
        _buildCorner(
          bottom: (size.height - scanAreaSize) / 2,
          left: (size.width - scanAreaSize) / 2,
          isTopLeft: false,
        ),
        _buildCorner(
          bottom: (size.height - scanAreaSize) / 2,
          right: (size.width - scanAreaSize) / 2,
          isTopLeft: true,
        ),

        // Animated scan line
        Positioned(
          top: (size.height - scanAreaSize) / 2,
          left: (size.width - scanAreaSize) / 2,
          right: (size.width - scanAreaSize) / 2,
          child: ScaleTransition(
            scale: _animationController,
            alignment: Alignment.center,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Status message and info
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (widget.message != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.message!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Scanning indicator
              if (widget.isActive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool isTopLeft = true,
  }) {
    const cornerSize = 30.0;
    const cornerThickness = 3.0;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: cornerSize,
        height: cornerSize,
        decoration: BoxDecoration(
          border: Border(
            top: isTopLeft
                ? const BorderSide(color: Colors.green, width: cornerThickness)
                : BorderSide.none,
            bottom: !isTopLeft
                ? const BorderSide(color: Colors.green, width: cornerThickness)
                : BorderSide.none,
            left: isTopLeft
                ? const BorderSide(color: Colors.green, width: cornerThickness)
                : BorderSide.none,
            right: !isTopLeft
                ? const BorderSide(color: Colors.green, width: cornerThickness)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
