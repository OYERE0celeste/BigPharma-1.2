/// ⌨️ Global Keyboard Scanner Service
///
/// Core service that handles keyboard input from hardware scanners.
/// Accumulates keyboard characters into barcode buffer.
/// Detects ENTER key to trigger scan processing.
/// Implements deduplication logic (cooldown + cache).
///
/// Lifecycle: Singleton, created at app start, never disposed
/// Scope: Global, accessible from anywhere
///
/// This is the HEART of the always-listening scanner system.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../products/services/product_api_service.dart';
import '../../models/product_model.dart';
import 'barcode_detection_engine.dart';
import 'scanner_event_bus.dart';
import 'scanner_focus_manager.dart';

/// ⌨️ Global keyboard scanner service
///
/// Responsibilities:
/// 1. Listen to raw keyboard events (from GlobalScannerListener)
/// 2. Accumulate characters into barcode buffer
/// 3. Detect ENTER key → trigger scan
/// 4. Validate barcode format
/// 5. Deduplication (prevent double-scans)
/// 6. Async product lookup
/// 7. Emit events via ScannerEventBus
class GlobalKeyboardScannerService {
  static final GlobalKeyboardScannerService _instance =
      GlobalKeyboardScannerService._internal();

  factory GlobalKeyboardScannerService() {
    return _instance;
  }

  static GlobalKeyboardScannerService get instance => _instance;

  GlobalKeyboardScannerService._internal() {
    _eventBus = ScannerEventBus();
    _focusManager = ScannerFocusManager();
  }

  // ========== CONFIGURATION ==========

  /// Cooldown period after scan (prevents double-scans)
  static const _cooldownMs = 150;

  /// Max barcode length (for buffer overflow protection)
  static const _maxBarcodeLength = 200;

  /// Characters to ignore/strip from barcode
  static const _ignoreChars = ['\n', '\r', '\t'];

  // ========== STATE ==========

  /// Current barcode being accumulated in buffer
  String _barcodeBuffer = '';

  /// Last successfully scanned barcode (for deduplication)
  String? _lastScannedBarcode;

  /// Timestamp of last scan (for cooldown calculation)
  DateTime? _lastScanTime;

  /// Whether currently in cooldown period
  bool _inCooldown = false;

  /// Whether currently processing a scan (async lookup)
  bool _isProcessing = false;

  /// Timer for auto-reset of buffer (if ENTER not detected)
  Timer? _bufferResetTimer;

  /// Remaining cooldown time in milliseconds
  int _remainingCooldownMs = 0;

  /// Statistics
  late int _totalScansDetected = 0;
  late int _totalProductsFound = 0;
  late int _totalProductsNotFound = 0;
  late int _totalDuplicatesBlocked = 0;
  late int _totalErrors = 0;

  // ========== DEPENDENCIES ==========

  late final ScannerEventBus _eventBus;
  late final ScannerFocusManager _focusManager;

  // ========== PUBLIC API ==========

  /// Get current barcode buffer content (for debugging)
  String get barcodeBuffer => _barcodeBuffer;

  /// Get last scanned barcode
  String? get lastScannedBarcode => _lastScannedBarcode;

  /// Whether currently processing scan
  bool get isProcessing => _isProcessing;

  /// Whether in cooldown period
  bool get inCooldown => _inCooldown;

  /// Remaining cooldown time (ms)
  int get remainingCooldownMs => _remainingCooldownMs;

  /// Total scans detected
  int get totalScansDetected => _totalScansDetected;

  /// Total products found
  int get totalProductsFound => _totalProductsFound;

  /// Total products not found
  int get totalProductsNotFound => _totalProductsNotFound;

  /// Total duplicates blocked
  int get totalDuplicatesBlocked => _totalDuplicatesBlocked;

  /// Total errors
  int get totalErrors => _totalErrors;

  // ========== KEYBOARD EVENT HANDLING ==========

  /// Handle keyboard event
  ///
  /// Called by GlobalScannerListener when any key is pressed.
  /// Decides:
  /// - Is this a printable character? → add to buffer
  /// - Is this ENTER? → process buffer as barcode
  /// - Is this BACKSPACE? → remove from buffer (optional)
  ///
  /// Parameters:
  /// - event: RawKeyEvent from keyboard listener
  Future<void> handleKeyEvent(RawKeyEvent event) async {
    // Only process key down events (not key up)
    if (event is! RawKeyDownEvent) return;

    // Extract character if available
    final character = event.character;

    // ========== CASE 1: REGULAR CHARACTER ==========
    if (character != null && character.isNotEmpty) {
      // Ignore control characters and special chars
      if (_ignoreChars.contains(character)) return;

      // Don't add newlines or carriage returns
      if (character == '\n' || character == '\r') return;

      // Add to buffer (with overflow protection)
      if (_barcodeBuffer.length < _maxBarcodeLength) {
        _barcodeBuffer += character;

        // Reset auto-reset timer
        _bufferResetTimer?.cancel();
        _bufferResetTimer = Timer(const Duration(milliseconds: 500), () {
          // If no ENTER pressed within 500ms, buffer might be corrupted
          debugPrint('⚠️ Buffer auto-reset (no ENTER detected)');
          _barcodeBuffer = '';
        });
      }
      return;
    }

    // ========== CASE 2: ENTER KEY ==========
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _bufferResetTimer?.cancel();
      await _processScan();
      return;
    }

    // ========== CASE 3: BACKSPACE (optional - for manual input) ==========
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_barcodeBuffer.isNotEmpty) {
        _barcodeBuffer = _barcodeBuffer.substring(0, _barcodeBuffer.length - 1);
      }
      return;
    }
  }

  /// Manually trigger scan (for testing or explicit input)
  ///
  /// Parameters:
  /// - barcode: The barcode to process
  /// - bypassCooldown: If true, ignore cooldown period
  Future<void> manualScan(String barcode, {bool bypassCooldown = false}) async {
    _barcodeBuffer = barcode;
    await _processScan(bypassCooldown: bypassCooldown);
  }

  // ========== INTERNAL PROCESSING ==========

  /// Process barcode from buffer
  ///
  /// This is called when ENTER key is detected.
  ///
  /// Flow:
  /// 1. Validate barcode format
  /// 2. Check for duplicates
  /// 3. Check cooldown
  /// 4. Lookup product (async)
  /// 5. Emit appropriate event
  /// 6. Restore focus
  /// 7. Reset buffer
  Future<void> _processScan({bool bypassCooldown = false}) async {
    final barcode = _barcodeBuffer.trim();

    // ========== VALIDATION ==========

    if (BarcodeDetectionEngine.shouldIgnore(barcode)) {
      debugPrint('⚠️ Ignoring empty/invalid barcode');
      _barcodeBuffer = '';
      return;
    }

    if (!BarcodeDetectionEngine.isValidBarcode(barcode)) {
      debugPrint('❌ Invalid barcode format: $barcode');
      _eventBus.emit(ScanError('Invalid barcode format'));
      _totalErrors++;
      _barcodeBuffer = '';
      return;
    }

    // ========== DUPLICATE CHECK ==========

    if (barcode == _lastScannedBarcode && !bypassCooldown) {
      if (_inCooldown) {
        debugPrint('⏱️ Duplicate scan blocked (cooldown active): $barcode');
        _eventBus.emit(ScanCooldown(barcode, _remainingCooldownMs));
        _totalDuplicatesBlocked++;
        _barcodeBuffer = '';
        return;
      }
    }

    // ========== COOLDOWN CHECK ==========

    if (!bypassCooldown && _lastScanTime != null) {
      final elapsed = DateTime.now().difference(_lastScanTime!).inMilliseconds;
      if (elapsed < _cooldownMs) {
        debugPrint(
          '⏱️ Cooldown period active: ${_cooldownMs - elapsed}ms remaining',
        );
        _eventBus.emit(ScanCooldown(barcode, _cooldownMs - elapsed));
        _totalDuplicatesBlocked++;
        _barcodeBuffer = '';
        return;
      }
    }

    // ========== START SCAN PROCESSING ==========

    _totalScansDetected++;
    _lastScannedBarcode = barcode;
    _lastScanTime = DateTime.now();
    _startCooldown();
    _barcodeBuffer = '';
    _isProcessing = true;

    // Emit scan detected event
    _eventBus.emit(ScanDetected(barcode));

    // Restore focus immediately
    _focusManager.requestFocus();

    // ========== PRODUCT LOOKUP (ASYNC) ==========

    try {
      final product = await _lookupProduct(barcode);

      if (product != null) {
        debugPrint('✓ Product found: ${product.name}');
        _totalProductsFound++;
        _eventBus.emit(ProductFound(product, barcode));
      } else {
        debugPrint('✗ Product not found: $barcode');
        _totalProductsNotFound++;
        _eventBus.emit(ProductNotFound(barcode));
      }
    } catch (e) {
      debugPrint('❌ Lookup error: $e');
      _totalErrors++;
      _eventBus.emit(ScanError('Product lookup failed: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  // ========== COOLDOWN MANAGEMENT ==========

  /// Start cooldown period (prevents double-scans)
  void _startCooldown() {
    _inCooldown = true;
    _remainingCooldownMs = _cooldownMs;

    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _remainingCooldownMs -= 10;

      if (_remainingCooldownMs <= 0) {
        _inCooldown = false;
        _remainingCooldownMs = 0;
        timer.cancel();
      }
    });
  }

  // ========== PRODUCT LOOKUP ==========

  /// Look up product by barcode
  ///
  /// First tries local database (ProductApiService).
  /// Could be extended to try external APIs if needed.
  Future<Product?> _lookupProduct(String barcode) async {
    try {
      // Try local database first
      return await ProductApiService.getProductByBarcode(barcode);
    } catch (e) {
      debugPrint('⚠️ Product lookup error: $e');
      return null;
    }
  }

  // ========== DEBUG & STATS ==========

  /// Get scanner status for debugging
  String getDebugStatus() {
    return '''
Global Keyboard Scanner Status:
- Buffer: "$_barcodeBuffer"
- Last Barcode: $_lastScannedBarcode
- Is Processing: $_isProcessing
- In Cooldown: $_inCooldown ($_remainingCooldownMs ms remaining)
- Total Detected: $_totalScansDetected
- Products Found: $_totalProductsFound
- Products Not Found: $_totalProductsNotFound
- Duplicates Blocked: $_totalDuplicatesBlocked
- Errors: $_totalErrors
- Buffer Length: ${_barcodeBuffer.length}
- Last Scan: $_lastScanTime
''';
  }

  /// Reset statistics
  void resetStats() {
    _totalScansDetected = 0;
    _totalProductsFound = 0;
    _totalProductsNotFound = 0;
    _totalDuplicatesBlocked = 0;
    _totalErrors = 0;
  }

  /// Clear buffer and reset state
  void clear() {
    _barcodeBuffer = '';
    _bufferResetTimer?.cancel();
    resetStats();
  }

  /// Clean up resources (on app shutdown)
  void dispose() {
    _bufferResetTimer?.cancel();
  }
}
