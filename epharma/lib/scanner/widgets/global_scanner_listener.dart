// 🎯 Global Scanner Listener Widget
//
// Root-level widget that enables global always-listening keyboard scanning.
//
// Placement: At MaterialApp level via builder property
// Lifecycle: Never disposed (app lifetime)
// Scope: Global keyboard capture for entire application
//
// This widget:
// 1. Provides RawKeyboardListener for ALL keyboard input
// 2. Maintains invisible TextField with global FocusNode
// 3. Forwards keyboard events to GlobalKeyboardScannerService
// 4. Ensures focus is always available for scanner input
// 5. Passes through to child widgets

import 'package:flutter/material.dart';

import '../services/global_keyboard_scanner_service.dart';
import '../services/scanner_focus_manager.dart';

/// 🎯 Global scanner listener - attach at app root
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => GlobalScannerListener(
///     child: AppNotificationHost(
///       child: child ?? const SizedBox.shrink(),
///     ),
///   ),
/// )
/// ```
class GlobalScannerListener extends StatefulWidget {
  final Widget child;
  final bool debugMode;

  const GlobalScannerListener({
    super.key,
    required this.child,
    this.debugMode = false,
  });

  @override
  State<GlobalScannerListener> createState() => _GlobalScannerListenerState();
}

class _GlobalScannerListenerState extends State<GlobalScannerListener> {
  late final GlobalKeyboardScannerService _scannerService;
  late final TextEditingController _dummyController;

  @override
  void initState() {
    super.initState();
    _scannerService = GlobalKeyboardScannerService();
    _dummyController = TextEditingController();

    debugPrint(
      '✓ GlobalScannerListener initialized - scanner now always listening',
    );
  }

  @override
  void dispose() {
    // NOTE: Do NOT dispose the scanner service - it's a singleton
    // that should persist for app lifetime
    _dummyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(
        onKey: (node, event) {
          // Forward all keyboard events to scanner service
          _scannerService.handleKeyEvent(event);
          // Return false to allow other widgets to also process
          return KeyEventResult.ignored;
        },
      ),
      child: Column(
        children: [
          // ========== INVISIBLE SCANNER INPUT FIELD ==========
          // This TextField maintains focus for keyboard events
          // It's invisible and doesn't disturb the UI
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: false,
            // Wrap the hidden TextField in a Material to satisfy Material-dependent widgets
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _dummyController,
                focusNode: _getFocusNode(),
                enabled: true,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [],
                // Accept all keyboard input
                onChanged: (_) {
                  // Text changes handled by RawKeyboardListener above
                },
              ),
            ),
          ),

          // ========== ACTUAL APP CONTENT ==========
          Expanded(child: widget.child),

          // ========== DEBUG INFO (Optional) ==========
          if (widget.debugMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Scanner Buffer: "${_scannerService.barcodeBuffer}"',
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Get the global focus node from ScannerFocusManager
  FocusNode _getFocusNode() {
    return ScannerFocusManager.instance.focusNode ?? FocusNode();
  }
}
