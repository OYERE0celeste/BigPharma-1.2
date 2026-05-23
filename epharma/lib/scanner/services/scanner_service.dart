import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/scan_result_model.dart';
import 'barcode_parser_service.dart';
import 'scan_cache_service.dart';

typedef ScanCallback = void Function(ScanResult result);
typedef ErrorCallback = void Function(String error);

/// Main scanner service for webcam barcode/QR code detection.
class ScannerService {
  static final ScannerService _instance = ScannerService._internal();

  factory ScannerService() {
    return _instance;
  }

  ScannerService._internal();

  MobileScannerController? _controller;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  bool _isStarting = false;

  final List<ScanCallback> _scanCallbacks = [];
  final List<ErrorCallback> _errorCallbacks = [];
  final ScanCacheService _cacheService = ScanCacheService();
  final ScannerStats _stats = ScannerStats();

  bool _isInitialized = false;
  bool _isActive = false;

  bool get isInitialized => _isInitialized;
  bool get isActive => _isActive;
  MobileScannerController? get controller => _controller;
  ScanCacheService get cacheService => _cacheService;
  ScannerStats get stats => _stats;

  Future<bool> initialize({
    List<BarcodeFormat>? formats,
    CameraFacing facing = CameraFacing.back,
    ScanCallback? onScan,
    ErrorCallback? onError,
  }) async {
    try {
      if (_isInitialized) {
        debugPrint('Scanner already initialized');
        return true;
      }

      if (onScan != null) {
        _scanCallbacks.add(onScan);
      }
      if (onError != null) {
        _errorCallbacks.add(onError);
      }

      _controller = MobileScannerController(
        facing: facing,
        formats: formats ?? const [
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.aztec,
          BarcodeFormat.pdf417,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.itf,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
        ],
        detectionSpeed: DetectionSpeed.unrestricted,
        detectionTimeoutMs: 0,
        autoZoom: true,
        autoStart: false,
      );

      _barcodeSubscription = _controller!.barcodes.listen(
        _handleDetection,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Scanner stream error: $error');
          _notifyError('Erreur de detection: $error');
        },
      );

      _isInitialized = true;
      debugPrint('Scanner initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Scanner initialization error: $e');
      _notifyError('Erreur d\'initialisation: $e');
      return false;
    }
  }

  Future<bool> start() async {
    try {
      final controller = _controller;
      if (!_isInitialized || controller == null) {
        debugPrint('Scanner not initialized');
        return false;
      }

      if (_isActive || _isStarting) {
        debugPrint('Scanner already active');
        return true;
      }

      _isStarting = true;
      await controller.start();
      _isActive = true;
      _isStarting = false;
      debugPrint('Scanner started');
      return true;
    } catch (e) {
      _isStarting = false;
      debugPrint('Scanner start error: $e');
      _notifyError('Erreur au demarrage du scanner: $e');
      return false;
    }
  }

  Future<void> pause() async {
    try {
      final controller = _controller;
      if (_isActive && controller != null) {
        await controller.pause();
        _isActive = false;
        debugPrint('Scanner paused');
      }
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      final controller = _controller;
      if (!_isActive && controller != null) {
        await controller.start();
        _isActive = true;
        _isStarting = false;
        debugPrint('Scanner resumed');
      }
    } catch (e) {
      _isStarting = false;
      debugPrint('Resume error: $e');
    }
  }

  Future<void> toggleTorch() async {
    try {
      await _controller?.toggleTorch();
      debugPrint('Torch toggled');
    } catch (e) {
      debugPrint('Torch toggle error: $e');
    }
  }

  Future<bool> hasTorch() async {
    try {
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) {
        return false;
      }
      return controller.value.torchState != TorchState.unavailable;
    } catch (_) {
      return false;
    }
  }

  Future<void> switchCamera() async {
    try {
      await _controller?.switchCamera();
      debugPrint('Camera switched');
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  void _handleDetection(BarcodeCapture capture) {
    try {
      final barcodes = capture.barcodes;
      if (barcodes.isEmpty) {
        return;
      }

      final barcode = barcodes.first;
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.isEmpty) {
        return;
      }

      final scanResult = BarcodeParserService.parse(
        rawValue,
        detectedFormat: barcode.format.name,
        confidence: 0.95,
      );

      if (!_cacheService.canScan(scanResult.rawValue)) {
        _stats.incrementDuplicate();
        debugPrint('Duplicate scan filtered: ${scanResult.rawValue}');
        return;
      }

      _cacheService.addScan(scanResult);
      _stats.totalScans++;
      _notifyScan(scanResult);

      debugPrint(
        'Scan detected: ${scanResult.rawValue} (${scanResult.codeType})',
      );
    } catch (e) {
      debugPrint('Detection handling error: $e');
      _notifyError('Erreur de detection: $e');
    }
  }

  void onScan(ScanCallback callback) {
    _scanCallbacks.add(callback);
  }

  void onError(ErrorCallback callback) {
    _errorCallbacks.add(callback);
  }

  void removeCallbacks() {
    _scanCallbacks.clear();
    _errorCallbacks.clear();
  }

  void _notifyScan(ScanResult result) {
    for (final callback in _scanCallbacks) {
      try {
        callback(result);
      } catch (e) {
        debugPrint('Callback error: $e');
      }
    }
  }

  void _notifyError(String error) {
    for (final callback in _errorCallbacks) {
      try {
        callback(error);
      } catch (e) {
        debugPrint('Error callback error: $e');
      }
    }
  }

  Map<String, dynamic> getStatistics() {
    return {
      ...stats.toMap(),
      ...cacheService.getStats(),
      'isActive': _isActive,
      'isInitialized': _isInitialized,
    };
  }

  Future<void> dispose() async {
    try {
      final controller = _controller;

      if (_isActive && controller != null) {
        await controller.stop();
      }

      await _barcodeSubscription?.cancel();
      _barcodeSubscription = null;

      if (controller != null) {
        await controller.dispose();
      }

      _controller = null;
      _isInitialized = false;
      _isActive = false;
      _isStarting = false;
      removeCallbacks();
      _cacheService.clear();

      debugPrint('Scanner disposed');
    } catch (e) {
      debugPrint('Dispose error: $e');
    }
  }
}
