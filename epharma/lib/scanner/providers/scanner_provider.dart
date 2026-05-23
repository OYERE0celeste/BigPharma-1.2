import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../products/services/product_api_service.dart';
import '../models/scan_result_model.dart';
import '../services/product_lookup_service.dart';
import '../services/scanner_service.dart';

enum ScannerState {
  idle,
  scanning,
  processing,
  found,
  notFound,
  lookupFound,
  error,
}

class ScannerProvider extends ChangeNotifier {
  final ScannerService _scannerService = ScannerService();

  ScannerState _state = ScannerState.idle;
  ScanResult? _lastScan;
  Product? _lastProduct;
  ProductLookupResult? _lookupResult;
  String? _errorMessage;
  bool _isScanning = false;
  bool _isLoading = false;
  bool _isHandlingScan = false;

  ScannerState get state => _state;
  ScanResult? get lastScan => _lastScan;
  Product? get lastProduct => _lastProduct;
  ProductLookupResult? get lookupResult => _lookupResult;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _isScanning;
  bool get isLoading => _isLoading;
  bool get isInitialized => _scannerService.isInitialized;
  bool get isActive => _scannerService.isActive;
  ScannerService get scannerService => _scannerService;

  Future<bool> initializeScanner({
    VoidCallback? onScan,
    Function(String)? onError,
  }) async {
    try {
      _state = ScannerState.idle;
      _errorMessage = null;
      notifyListeners();

      final success = await _scannerService.initialize(
        onScan: (result) {
          _handleScanResult(result);
          onScan?.call();
        },
        onError: (error) {
          _handleError(error);
          onError?.call(error);
        },
      );

      if (!success) {
        _errorMessage = 'Impossible d\'initialiser le scanner';
        _state = ScannerState.error;
      }

      notifyListeners();
      return success;
    } catch (e) {
      _handleError('Erreur: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> startScanning() async {
    try {
      if (!_scannerService.isInitialized) {
        _handleError('Scanner not initialized');
        notifyListeners();
        return;
      }

      _state = ScannerState.scanning;
      _errorMessage = null;
      _isScanning = true;
      notifyListeners();

      await _scannerService.start();
    } catch (e) {
      _handleError('Erreur au demarrage: $e');
      notifyListeners();
    }
  }

  Future<void> pauseScanning() async {
    try {
      _isScanning = false;
      if (_state == ScannerState.scanning) {
        _state = ScannerState.idle;
      }
      await _scannerService.pause();
      notifyListeners();
    } catch (e) {
      _handleError('Erreur de pause: $e');
      notifyListeners();
    }
  }

  Future<void> resumeScanning() async {
    try {
      _isScanning = true;
      _state = ScannerState.scanning;
      _errorMessage = null;
      notifyListeners();

      await _scannerService.resume();
    } catch (e) {
      _handleError('Erreur de reprise: $e');
      notifyListeners();
    }
  }

  Future<void> toggleTorch() async {
    try {
      await _scannerService.toggleTorch();
      notifyListeners();
    } catch (e) {
      _handleError('Erreur: $e');
      notifyListeners();
    }
  }

  Future<void> _handleScanResult(ScanResult scan) async {
    if (_isHandlingScan) {
      return;
    }

    try {
      _isHandlingScan = true;
      _lastScan = scan;
      _state = ScannerState.processing;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _scannerService.pause();
      _isScanning = false;

      final resolution = await _resolveProduct(scan.rawValue);

      _lastProduct = resolution.product;
      _lookupResult = resolution.lookupResult;

      if (resolution.product != null) {
        _state = ScannerState.found;
        _scannerService.stats.incrementSuccess();
      } else if (resolution.lookupResult != null) {
        _state = ScannerState.lookupFound;
        _errorMessage = resolution.localLookupFailed
            ? 'Base locale indisponible, informations recuperees en ligne'
            : 'Produit non trouve localement, informations recuperees en ligne';
        _scannerService.stats.incrementSuccess();
      } else {
        _state = ScannerState.notFound;
        _errorMessage = resolution.localLookupFailed
            ? 'Produit non trouve, aucune donnee recuperee en ligne'
            : 'Produit non trouve';
        _scannerService.stats.incrementNotFound();
      }
    } catch (e) {
      _handleError('Erreur de traitement: $e');
    } finally {
      _isHandlingScan = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> searchByBarcode(String barcode) async {
    try {
      _state = ScannerState.processing;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final resolution = await _resolveProduct(
        barcode,
        localLookup: () => ProductApiService.getProductByBarcode(barcode),
      );

      _lastProduct = resolution.product;
      _lookupResult = resolution.lookupResult;

      if (resolution.product != null) {
        _state = ScannerState.found;
      } else if (resolution.lookupResult != null) {
        _state = ScannerState.lookupFound;
        _errorMessage = resolution.localLookupFailed
            ? 'Base locale indisponible, informations en ligne disponibles'
            : 'Produit non trouve localement, informations en ligne disponibles';
      } else {
        _state = ScannerState.notFound;
        _errorMessage = 'Produit non trouve';
      }

      return resolution.product;
    } catch (e) {
      _handleError('Erreur: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> searchByQRCode(String qrCode) async {
    try {
      _state = ScannerState.processing;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final resolution = await _resolveProduct(
        qrCode,
        localLookup: () => ProductApiService.getProductByQRCode(qrCode),
      );

      _lastProduct = resolution.product;
      _lookupResult = resolution.lookupResult;

      if (resolution.product != null) {
        _state = ScannerState.found;
      } else if (resolution.lookupResult != null) {
        _state = ScannerState.lookupFound;
        _errorMessage = resolution.localLookupFailed
            ? 'Base locale indisponible, informations en ligne disponibles'
            : 'Produit non trouve localement, informations en ligne disponibles';
      } else {
        _state = ScannerState.notFound;
        _errorMessage = 'Produit non trouve';
      }

      return resolution.product;
    } catch (e) {
      _handleError('Erreur: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<_LookupResolution> _resolveProduct(
    String code, {
    Future<Product?> Function()? localLookup,
  }) async {
    var localLookupFailed = false;
    Product? product;

    try {
      product = await (localLookup?.call() ?? _searchProductByCode(code));
    } catch (e) {
      localLookupFailed = true;
      debugPrint('Local lookup failed for $code: $e');
    }

    if (product != null) {
      return _LookupResolution(
        product: product,
        lookupResult: null,
        localLookupFailed: localLookupFailed,
      );
    }

    final lookupResult = await _searchExternalProduct(code);
    return _LookupResolution(
      product: null,
      lookupResult: lookupResult,
      localLookupFailed: localLookupFailed,
    );
  }

  Future<Product?> _searchProductByCode(String code) async {
    return ProductApiService.getProductByCode(code);
  }

  Future<ProductLookupResult?> _searchExternalProduct(String code) async {
    try {
      return await ProductLookupService.lookupCode(code);
    } catch (e) {
      debugPrint('External lookup failed for $code: $e');
      return null;
    }
  }

  void clearLastScan() {
    _lastScan = null;
    _lastProduct = null;
    _lookupResult = null;
    _errorMessage = null;
    _isHandlingScan = false;
    _state = ScannerState.idle;
    _resumeScannerAfterClear();
    notifyListeners();
  }

  Future<void> _resumeScannerAfterClear() async {
    if (!_scannerService.isInitialized) {
      return;
    }

    await _scannerService.resume();
    _isScanning = true;
    if (_state == ScannerState.idle) {
      _state = ScannerState.scanning;
    }
    notifyListeners();
  }

  Future<void> shutdownScanner({bool notify = true}) async {
    _lastScan = null;
    _lastProduct = null;
    _lookupResult = null;
    _errorMessage = null;
    _isScanning = false;
    _isLoading = false;
    _isHandlingScan = false;
    _state = ScannerState.idle;

    await _scannerService.dispose();

    if (notify) {
      notifyListeners();
    }
  }

  void _handleError(String error) {
    _state = ScannerState.error;
    _errorMessage = error;
    _isLoading = false;
    debugPrint('Scanner error: $error');
  }

  Map<String, dynamic> getStats() {
    return _scannerService.getStatistics();
  }

  @override
  void dispose() {
    shutdownScanner(notify: false);
    super.dispose();
  }
}

class _LookupResolution {
  final Product? product;
  final ProductLookupResult? lookupResult;
  final bool localLookupFailed;

  const _LookupResolution({
    required this.product,
    required this.lookupResult,
    required this.localLookupFailed,
  });
}
