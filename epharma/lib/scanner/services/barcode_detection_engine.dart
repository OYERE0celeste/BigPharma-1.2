// 📊 Barcode Detection Engine
//
// Validates and detects barcode formats globally.
// Supports: EAN-13, EAN-8, UPC-A, UPC-E, Code-128, QR, Code-39
//
// This engine works independently from input source (keyboard, camera, USB scanner).
// Pure validation logic - no UI, no state management.

/// Supported barcode formats
enum BarcodeFormat {
  ean13, // 13 digits
  ean8, // 8 digits
  upcA, // 12 digits
  upcE, // 6-8 digits
  code128,
  code39,
  qrCode,
  unknown,
}

/// 🔍 Barcode validation and format detection
class BarcodeDetectionEngine {
  /// Check if input looks like a valid barcode
  ///
  /// Returns false for:
  /// - Empty strings
  /// - Only whitespace
  /// - Too short (< 3 chars)
  /// - Too long (> 200 chars - QR limit)
  /// - Invalid characters
  static bool isValidBarcode(String input) {
    if (input.isEmpty) return false;

    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length < 3) return false;
    if (trimmed.length > 200) return false;

    // Check for valid characters
    // Barcodes can contain: digits, letters, some special chars
    // QR codes have broader character support
    return RegExp(r'^[A-Za-z0-9\-\.%\s]+$').hasMatch(trimmed);
  }

  /// Attempt to detect barcode format
  static BarcodeFormat detectFormat(String barcode) {
    final cleaned = barcode.trim().replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) return BarcodeFormat.unknown;

    // Check length first (fastest detection)
    final length = cleaned.length;

    // EAN-13: exactly 13 digits
    if (length == 13 && _isAllDigits(cleaned)) {
      if (isValidEAN13(cleaned)) return BarcodeFormat.ean13;
    }

    // EAN-8: exactly 8 digits
    if (length == 8 && _isAllDigits(cleaned)) {
      if (isValidEAN8(cleaned)) return BarcodeFormat.ean8;
    }

    // UPC-A: 12 digits (similar to EAN-13 without leading 0)
    if (length == 12 && _isAllDigits(cleaned)) {
      if (isValidEAN13('0$cleaned')) return BarcodeFormat.upcA;
    }

    // UPC-E: 6-8 characters
    if ((length == 6 || length == 8) && _isAllDigits(cleaned)) {
      return BarcodeFormat.upcE;
    }

    // Code-128: alphanumeric, variable length (10-50 chars typical)
    if (length >= 10 && length <= 50 && _isCode128(cleaned)) {
      return BarcodeFormat.code128;
    }

    // Code-39: alphanumeric with special chars allowed
    if (length >= 5 && _isCode39(cleaned)) {
      return BarcodeFormat.code39;
    }

    // QR Code: typically 20-150 chars, alphanumeric with symbols
    if (length >= 20 && length <= 200) {
      return BarcodeFormat.qrCode;
    }

    return BarcodeFormat.unknown;
  }

  /// ✓ Validate EAN-13 checksum (Luhn algorithm)
  ///
  /// EAN-13 format: GTIN-13 with checksum
  /// - Positions 1-12: product code
  /// - Position 13: checksum digit
  static bool isValidEAN13(String code) {
    if (code.length != 13 || !_isAllDigits(code)) return false;

    // Extract digits and calculate checksum
    final digits = code.split('').map(int.parse).toList();
    final checksum = _calculateEANChecksum(code.substring(0, 12));

    return digits[12] == checksum;
  }

  /// ✓ Validate EAN-8 checksum (Luhn algorithm)
  static bool isValidEAN8(String code) {
    if (code.length != 8 || !_isAllDigits(code)) return false;

    final digits = code.split('').map(int.parse).toList();
    final checksum = _calculateEANChecksum(code.substring(0, 7));

    return digits[7] == checksum;
  }

  /// Calculate EAN checksum digit using Luhn algorithm
  ///
  /// Algorithm:
  /// 1. Starting from right, multiply digits by 1, 3, 1, 3, ...
  /// 2. Sum all results
  /// 3. Subtract from nearest equal or higher multiple of 10
  static int _calculateEANChecksum(String code) {
    final digits = code.split('').map(int.parse).toList();
    int sum = 0;

    for (int i = 0; i < digits.length; i++) {
      final multiplier = (i % 2 == 0) ? 1 : 3;
      sum += digits[i] * multiplier;
    }

    final remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }

  /// Check if input should be ignored (invalid/empty)
  static bool shouldIgnore(String input) {
    if (input.isEmpty) return true;
    if (input.trim().isEmpty) return true;

    // Ignore common non-barcode sequences
    final common = [
      '*', // Common scan prefix
      '#', // Common scan suffix
      '~', // Scan separator
      '**', // Double star
    ];

    for (final pattern in common) {
      if (input.trim() == pattern) return true;
    }

    return false;
  }

  /// Get human-readable format name
  static String formatName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code-128';
      case BarcodeFormat.code39:
        return 'Code-39';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.unknown:
        return 'Unknown';
    }
  }

  // ======== PRIVATE HELPERS ========

  static bool _isAllDigits(String s) => RegExp(r'^\d+$').hasMatch(s);

  static bool _isCode128(String s) {
    // Code-128 typically alphanumeric, more permissive
    return RegExp(r'^[A-Za-z0-9\-\.\s]+$').hasMatch(s);
  }

  static bool _isCode39(String s) {
    // Code-39: A-Z, 0-9, space, and - . $ / + %
    return RegExp(r'^[A-Za-z0-9\-\.\s\$\/\+%]+$').hasMatch(s);
  }
}
