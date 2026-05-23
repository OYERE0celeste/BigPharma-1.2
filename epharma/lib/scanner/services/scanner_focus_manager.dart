/// 📌 Scanner Focus Manager
///
/// Global focus management for the scanner input field.
/// Ensures scanner input field ALWAYS has focus for keyboard events.
///
/// Responsibilities:
/// - Maintain global FocusNode (never disposed)
/// - Auto-restore focus after dialog/navigation
/// - Track focus state
/// - Handle focus conflicts
library;

import 'package:flutter/material.dart';

/// 📌 Global focus manager for keyboard scanner input
///
/// Singleton pattern - use ScannerFocusManager.instance
///
/// This maintains a PERSISTENT FocusNode that:
/// - Never gets disposed during app lifetime
/// - Survives page navigation
/// - Survives dialog opens/closes
/// - Auto-restores after losing focus
class ScannerFocusManager {
  static final ScannerFocusManager _instance = ScannerFocusManager._internal();

  factory ScannerFocusManager() {
    return _instance;
  }

  static ScannerFocusManager get instance => _instance;

  ScannerFocusManager._internal() {
    _focusNode = FocusNode();
    _focusNode!.addListener(_onFocusChanged);
  }

  /// Global FocusNode for scanner input
  ///
  /// This FocusNode:
  /// - Is created once at startup
  /// - Never disposed (persists entire app lifecycle)
  /// - Is used by the global invisible TextField
  /// - Should always have focus when scanner is active
  FocusNode? _focusNode;

  /// Whether scanner input currently has focus
  bool _hasFocus = false;

  /// Whether focus restoration is enabled
  bool _focusRestoreEnabled = true;

  /// Number of times focus was lost and restored
  int _focusRestoreCount = 0;

  /// Timestamp of last focus change
  DateTime? _lastFocusChangeTime;

  // ========== PUBLIC API ==========

  /// Get the global FocusNode for scanner input
  ///
  /// This should be attached to the invisible TextField
  FocusNode? get focusNode => _focusNode;

  /// Whether scanner input currently has focus
  bool get hasFocus => _hasFocus;

  /// Number of times focus was restored
  int get focusRestoreCount => _focusRestoreCount;

  /// Request focus for scanner input
  ///
  /// Call this after handling a scan to ensure next keyboard input works.
  void requestFocus() {
    if (_focusNode?.canRequestFocus ?? false) {
      _focusNode!.requestFocus();
      _lastFocusChangeTime = DateTime.now();
    }
  }

  /// Release focus from scanner input
  ///
  /// Use when scanner should be temporarily disabled.
  void releaseFocus() {
    _focusNode?.unfocus();
  }

  /// Enable focus restoration
  ///
  /// When enabled, focus is automatically restored if lost.
  void enableFocusRestore() {
    _focusRestoreEnabled = true;
    if (!_hasFocus) {
      requestFocus();
    }
  }

  /// Disable focus restoration
  ///
  /// When disabled, focus stays released until explicitly requested.
  void disableFocusRestore() {
    _focusRestoreEnabled = false;
  }

  /// Whether focus restoration is enabled
  bool get isFocusRestoreEnabled => _focusRestoreEnabled;

  /// Get time since last focus change
  Duration? get timeSinceLastFocusChange {
    final lastTime = _lastFocusChangeTime;
    if (lastTime == null) return null;
    return DateTime.now().difference(lastTime);
  }

  /// Get focus status for debugging
  String getDebugStatus() {
    return '''
Scanner Focus Status:
- Has Focus: $_hasFocus
- Focus Node Valid: ${_focusNode != null}
- Can Request Focus: ${_focusNode?.canRequestFocus ?? false}
- Focus Restore Enabled: $_focusRestoreEnabled
- Focus Restore Count: $_focusRestoreCount
- Last Focus Change: $_lastFocusChangeTime
''';
  }

  // ========== PRIVATE LISTENERS ==========

  void _onFocusChanged() {
    final newState = _focusNode?.hasFocus ?? false;

    if (newState != _hasFocus) {
      _hasFocus = newState;
      _lastFocusChangeTime = DateTime.now();

      if (!newState && _focusRestoreEnabled) {
        // Focus was lost - restore it
        _focusRestoreCount++;
        Future.delayed(const Duration(milliseconds: 50), () {
          requestFocus();
        });
      }
    }
  }

  /// Clean up resources (called on app shutdown)
  void dispose() {
    _focusNode?.removeListener(_onFocusChanged);
    _focusNode?.dispose();
    _focusNode = null;
  }
}

/// 🛡️ Focus restoration strategies for different scenarios
class FocusRestorationStrategy {
  /// Strategy: Immediate focus restoration
  ///
  /// Restore focus immediately after event.
  /// Best for: Quick operations (add to cart, etc)
  static Future<void> immediate(ScannerFocusManager manager) async {
    manager.requestFocus();
  }

  /// Strategy: Delayed focus restoration
  ///
  /// Restore focus after short delay (allows UI updates).
  /// Best for: Dialog opens, animations
  static Future<void> delayed(
    ScannerFocusManager manager, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    await Future.delayed(delay);
    manager.requestFocus();
  }

  /// Strategy: Conditional focus restoration
  ///
  /// Only restore if dialog was closed.
  /// Best for: Dialog handling
  static Future<void> conditional(
    ScannerFocusManager manager,
    bool Function() shouldRestore, {
    Duration checkDelay = const Duration(milliseconds: 50),
  }) async {
    await Future.delayed(checkDelay);
    if (shouldRestore()) {
      manager.requestFocus();
    }
  }

  /// Strategy: Priority focus restoration
  ///
  /// Request focus with specific priority level.
  /// Used to break focus conflicts.
  static Future<void> prioritized(
    ScannerFocusManager manager, {
    int priority = 100,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    await Future.delayed(delay);
    manager.requestFocus();
  }
}
