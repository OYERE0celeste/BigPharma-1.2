// 📊 Scanner Status Overlay
// 
// Visual indicator showing:
// - 🟢 Scanner is active and listening
// - 🔴 Scanner is inactive
// - Last scan information
// - Error messages
// 
// Placement: Top corner of screen (FloatingOverlay style)
// Lifecycle: Persistent (attached to root)

import 'dart:async';
import 'package:flutter/material.dart';

import '../services/global_keyboard_scanner_service.dart';
import '../services/scanner_event_bus.dart';

/// 📊 Scanner status overlay widget
/// 
/// Shows real-time scanner status in corner of screen.
/// Useful for debugging and user feedback.
/// 
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     MainContent(),
///     ScannerStatusOverlay(),
///   ],
/// )
/// ```
class ScannerStatusOverlay extends StatefulWidget {
  /// Position: topRight (default), topLeft, bottomRight, bottomLeft
  final AlignmentGeometry alignment;

  /// Show detailed debug information
  final bool showDebugInfo;

  /// Opacity of overlay
  final double opacity;

  /// Auto-hide after no activity for this duration (null = always show)
  final Duration? autoHideDuration;

  const ScannerStatusOverlay({
    super.key,
    this.alignment = Alignment.topRight,
    this.showDebugInfo = false,
    this.opacity = 0.9,
    this.autoHideDuration = const Duration(seconds: 5),
  });

  @override
  State<ScannerStatusOverlay> createState() => _ScannerStatusOverlayState();
}

class _ScannerStatusOverlayState extends State<ScannerStatusOverlay> {
  late final GlobalKeyboardScannerService _scannerService;
  late final ScannerEventBus _eventBus;

  String? _lastBarcode;
  DateTime? _lastScanTime;
  String? _lastError;
  bool _showOverlay = true;
  late DateTime _lastActivityTime;

  @override
  void initState() {
    super.initState();
    _scannerService = GlobalKeyboardScannerService();
    _eventBus = ScannerEventBus();
    _lastActivityTime = DateTime.now();

    // Subscribe to events for UI updates
    _subscribeToEvents();

    // Setup auto-hide timer if configured
    if (widget.autoHideDuration != null) {
      _setupAutoHide();
    }
  }

  void _subscribeToEvents() {
    _eventBus.on<ScanDetected>().listen((event) {
      setState(() {
        _lastBarcode = event.barcode;
        _lastScanTime = event.timestamp;
        _lastError = null;
        _lastActivityTime = DateTime.now();
        _showOverlay = true;
      });
    });

    _eventBus.on<ScanError>().listen((event) {
      setState(() {
        _lastError = event.message;
        _lastActivityTime = DateTime.now();
        _showOverlay = true;
      });
    });

    _eventBus.on<ProductAddedToCart>().listen((event) {
      setState(() {
        _lastActivityTime = DateTime.now();
        _showOverlay = true;
      });
    });
  }

  void _setupAutoHide() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.autoHideDuration != null) {
        final elapsed = DateTime.now().difference(_lastActivityTime);
        if (elapsed > widget.autoHideDuration!) {
          if (_showOverlay) {
            setState(() => _showOverlay = false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay && widget.autoHideDuration != null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            // Tap to show/hide
            setState(() => _showOverlay = !_showOverlay);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(widget.opacity),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== STATUS LINE ==========
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status text
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // ========== LAST SCAN INFO ==========
                if (_lastBarcode != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last: $_lastBarcode',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_lastScanTime != null)
                    Text(
                      _formatTime(_lastScanTime!),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                ],

                // ========== ERROR INFO ==========
                if (_lastError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ ${_lastError!}',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // ========== DEBUG INFO ==========
                if (widget.showDebugInfo) ...[
                  const SizedBox(height: 8),
                  const Divider(
                    color: Colors.white24,
                    height: 8,
                  ),
                  _buildDebugInfo(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_lastError != null) return Colors.redAccent;
    if (_scannerService.inCooldown) return Colors.orangeAccent;
    if (_scannerService.isProcessing) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  String _getStatusText() {
    if (_lastError != null) return '🔴 Error';
    if (_scannerService.inCooldown) {
      return '⏱️ Cooldown (${_scannerService.remainingCooldownMs}ms)';
    }
    if (_scannerService.isProcessing) return '🔄 Processing...';
    return '🟢 Active';
  }

  String _formatTime(DateTime time) {
    final elapsed = DateTime.now().difference(time);
    if (elapsed.inSeconds < 60) {
      return '${elapsed.inSeconds}s ago';
    } else if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes}m ago';
    } else {
      return '${elapsed.inHours}h ago';
    }
  }

  Widget _buildDebugInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _debugRow('Buffer', '"${_scannerService.barcodeBuffer}"'),
        _debugRow('Total Scans', '${_scannerService.totalScansDetected}'),
        _debugRow('Found', '${_scannerService.totalProductsFound}'),
        _debugRow('Not Found', '${_scannerService.totalProductsNotFound}'),
        _debugRow('Blocked', '${_scannerService.totalDuplicatesBlocked}'),
        _debugRow('Errors', '${_scannerService.totalErrors}'),
      ],
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
