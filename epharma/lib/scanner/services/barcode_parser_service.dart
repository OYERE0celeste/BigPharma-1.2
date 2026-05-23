import 'package:flutter/foundation.dart';
import '../models/scan_result_model.dart';

/// 🎯 Service for parsing and validating various barcode formats
class BarcodeParserService {
  /// Standard barcode formats
  static const List<String> supportedFormats = [
    'QR_CODE',
    'EAN_13',
    'EAN_8',
    'UPC_A',
    'UPC_E',
    'CODE_128',
    'CODE_39',
    'CODE_93',
    'CODABAR',
    'DATA_MATRIX',
    'AZTEC',
  ];

  /// Parse and validate a barcode/QR code value
  /// Returns enriched ScanResult with metadata
  static ScanResult parse(
    String rawValue, {
    String? detectedFormat,
    double? confidence,
  }) {
    final normalized = _normalize(rawValue);
    final format = _detectFormat(normalized);
    final isValid = _validate(normalized, format);

    return ScanResult(
      rawValue: normalized,
      codeType: format,
      timestamp: DateTime.now(),
      confidence: confidence,
      metadata: {
        'valid': isValid,
        'originalValue': rawValue,
        'detectedFormat': detectedFormat,
        'normalizedValue': normalized,
        'checksumValid': _validateChecksum(normalized, format),
        'length': normalized.length,
      },
    );
  }

  /// Normalize barcode value
  /// - Trim whitespace
  /// - Convert to uppercase (for QR codes)
  /// - Remove special formatting
  static String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'[\s\-\.\/]'), '');
  }

  /// Detect barcode format from value
  static String _detectFormat(String value) {
    // QR Code detection (alphanumeric, usually longer)
    if (value.length > 20 || value.contains(RegExp(r'[a-zA-Z]'))) {
      // Could be QR if contains letters or long
      if (_isValidQRCode(value)) {
        return 'qrcode';
      }
    }

    // EAN-13 (12-13 digits)
    if (value.length == 12 || value.length == 13) {
      if (_isNumeric(value)) {
        return 'ean13';
      }
    }

    // EAN-8 (7-8 digits)
    if (value.length == 7 || value.length == 8) {
      if (_isNumeric(value)) {
        return 'ean8';
      }
    }

    // UPC-A (12 digits)
    if (value.length == 12 && _isNumeric(value)) {
      return 'upc';
    }

    // Code 128 (alphanumeric, typically 10-30 chars)
    if (value.length >= 10 && value.length <= 30) {
      return 'code128';
    }

    // Code 39 (alphanumeric, typically 5-30 chars)
    if (value.length >= 5 && value.length <= 30) {
      return 'code39';
    }

    // Default: generic barcode
    return 'barcode';
  }

  /// Validate barcode format
  static bool _validate(String value, String format) {
    if (value.isEmpty) return false;

    switch (format) {
      case 'ean13':
        return value.length == 12 || value.length == 13;
      case 'ean8':
        return value.length == 8 || value.length == 7;
      case 'upc':
        return value.length == 12;
      case 'code128':
        return value.length >= 10;
      case 'code39':
        return value.length >= 5;
      case 'qrcode':
        return value.isNotEmpty;
      default:
        return value.length >= 3; // Minimum length
    }
  }

  /// Validate barcode checksum (EAN-13, EAN-8, UPC)
  static bool _validateChecksum(String value, String format) {
    try {
      if (!_isNumeric(value)) return false;

      if (format == 'ean13' && (value.length == 12 || value.length == 13)) {
        return _validateEAN13(value);
      } else if (format == 'ean8' && (value.length == 8 || value.length == 7)) {
        return _validateEAN8(value);
      } else if (format == 'upc' && value.length == 12) {
        return _validateUPC(value);
      }
      return true; // Other formats don't require checksum
    } catch (e) {
      debugPrint('Checksum validation error: $e');
      return false;
    }
  }

  /// Validate EAN-13 checksum
  static bool _validateEAN13(String code) {
    if (code.length < 12) return false;

    final digits = code.substring(0, 12);
    int sum = 0;

    for (int i = 0; i < 12; i++) {
      int digit = int.parse(digits[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    int checksum = (10 - (sum % 10)) % 10;
    int providedChecksum = int.parse(code.length == 13 ? code[12] : '0');

    return checksum == providedChecksum;
  }

  /// Validate EAN-8 checksum
  static bool _validateEAN8(String code) {
    if (code.length < 7) return false;

    final digits = code.substring(0, 7);
    int sum = 0;

    for (int i = 0; i < 7; i++) {
      int digit = int.parse(digits[i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }

    int checksum = (10 - (sum % 10)) % 10;
    int providedChecksum = int.parse(code.length == 8 ? code[7] : '0');

    return checksum == providedChecksum;
  }

  /// Validate UPC checksum
  static bool _validateUPC(String code) {
    if (code.length != 12) return false;

    int sum = 0;
    for (int i = 0; i < 11; i++) {
      int digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }

    int checksum = (10 - (sum % 10)) % 10;
    int providedChecksum = int.parse(code[11]);

    return checksum == providedChecksum;
  }

  /// Check if string is numeric
  static bool _isNumeric(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  /// Check if value could be a valid QR code
  static bool _isValidQRCode(String value) {
    // QR codes are typically longer or contain non-numeric characters
    return value.length > 15 || value.contains(RegExp(r'[a-zA-Z:]'));
  }

  /// Get human-readable format name
  static String getFormatName(String format) {
    const formatNames = {
      'qrcode': 'Code QR',
      'ean13': 'EAN-13',
      'ean8': 'EAN-8',
      'upc': 'UPC',
      'code128': 'Code 128',
      'code39': 'Code 39',
      'barcode': 'Code-Barres',
    };
    return formatNames[format] ?? 'Inconnu';
  }

  /// Extract product ID from QR code URL if applicable
  /// Common QR code URLs: https://example.com/products/{id}
  static String? extractProductIdFromQR(String qrValue) {
    try {
      final uri = Uri.tryParse(qrValue);
      if (uri == null) return null;

      // Check for common patterns
      if (uri.path.contains('products')) {
        final parts = uri.path.split('/');
        final index = parts.indexWhere((p) => p == 'products');
        if (index >= 0 && index < parts.length - 1) {
          return parts[index + 1];
        }
      }

      // Check query parameter
      return uri.queryParameters['id'] ?? uri.queryParameters['product_id'];
    } catch (e) {
      debugPrint('Error extracting product ID from QR: $e');
      return null;
    }
  }
}
