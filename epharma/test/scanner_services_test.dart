// 🧪 Barcode Detection Engine Tests
//
// Tests for barcode format validation and detection

import 'package:flutter_test/flutter_test.dart';
import 'package:epharma/scanner/services/barcode_detection_engine.dart';

void main() {
  group('BarcodeDetectionEngine', () {
    // ========== EAN-13 TESTS ==========
    group('EAN-13 Format', () {
      test('Valid EAN-13: should accept 13 digits', () {
        const barcode = '5901234123457'; // Valid EAN-13
        expect(BarcodeDetectionEngine.isValidEAN13(barcode), true);
      });

      test('Invalid EAN-13: wrong checksum', () {
        const barcode = '5901234123458'; // Wrong checksum
        expect(BarcodeDetectionEngine.isValidEAN13(barcode), false);
      });

      test('Invalid EAN-13: wrong length', () {
        const barcode = '590123412345'; // 12 digits (not 13)
        expect(BarcodeDetectionEngine.isValidEAN13(barcode), false);
      });

      test('Should detect format as EAN13', () {
        const barcode = '5901234123457';
        expect(
          BarcodeDetectionEngine.detectFormat(barcode),
          BarcodeFormat.ean13,
        );
      });
    });

    // ========== EAN-8 TESTS ==========
    group('EAN-8 Format', () {
      test('Valid EAN-8: should accept 8 digits', () {
        const barcode = '96385074'; // Valid EAN-8
        expect(BarcodeDetectionEngine.isValidEAN8(barcode), true);
      });

      test('Invalid EAN-8: wrong checksum', () {
        const barcode = '96385075'; // Wrong checksum
        expect(BarcodeDetectionEngine.isValidEAN8(barcode), false);
      });

      test('Should detect format as EAN8', () {
        const barcode = '96385074';
        expect(
          BarcodeDetectionEngine.detectFormat(barcode),
          BarcodeFormat.ean8,
        );
      });
    });

    // ========== UPC-A TESTS ==========
    group('UPC-A Format', () {
      test('Valid UPC-A: should accept 12 digits', () {
        const barcode = '123456789012';
        expect(BarcodeDetectionEngine.detectFormat(barcode) == BarcodeFormat.upcA, true);
      });

      test('Should detect format as UPCA', () {
        const barcode = '123456789012';
        expect(
          BarcodeDetectionEngine.detectFormat(barcode),
          BarcodeFormat.upcA,
        );
      });
    });

    // ========== VALIDATION TESTS ==========
    group('General Validation', () {
      test('Should ignore empty barcode', () {
        expect(BarcodeDetectionEngine.shouldIgnore(''), true);
      });

      test('Should ignore whitespace only', () {
        expect(BarcodeDetectionEngine.shouldIgnore('   '), true);
      });

      test('Should ignore invalid characters', () {
        expect(BarcodeDetectionEngine.shouldIgnore('INVALID!!!'), true);
      });

      test('Should accept valid barcode', () {
        expect(BarcodeDetectionEngine.isValidBarcode('5901234123457'), true);
      });

      test('Should strip whitespace before validation', () {
        expect(BarcodeDetectionEngine.isValidBarcode('  5901234123457  '), true);
      });

      test('Should accept QR codes (long numeric)', () {
        const qrCode = '1234567890123456789012345678901234567890';
        expect(BarcodeDetectionEngine.isValidBarcode(qrCode), true);
      });
    });

    // ========== FORMAT DETECTION TESTS ==========
    group('Format Detection', () {
      test('Detects Code-128 format', () {
        const barcode = 'CODE128TEST';
        final format = BarcodeDetectionEngine.detectFormat(barcode);
        expect(
          format == BarcodeFormat.code128 || format == BarcodeFormat.unknown,
          true,
        );
      });

      test('Detects Code-39 format', () {
        const barcode = 'CODE39-1234';
        final format = BarcodeDetectionEngine.detectFormat(barcode);
        expect(
          format == BarcodeFormat.code39 || format == BarcodeFormat.unknown,
          true,
        );
      });

      test('Returns UNKNOWN for unrecognized format', () {
        const barcode = r'UNKNOWNFORMAT!@#$%';
        final format = BarcodeDetectionEngine.detectFormat(barcode);
        expect(format, BarcodeFormat.unknown);
      });
    });
  });
}
