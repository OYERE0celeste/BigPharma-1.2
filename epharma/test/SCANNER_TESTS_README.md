🧪 Scanner System - Testing Guide
==================================

# Overview

Comprehensive test suite for the global scanner system, covering:
- Unit tests for barcode detection
- Integration tests for complete scanner workflow
- Performance benchmarks
- Error handling scenarios

---

# Test Files

## 1. `scanner_services_test.dart`

**Purpose:** Unit tests for BarcodeDetectionEngine

**Coverage:**
- ✓ EAN-13 validation (valid, invalid checksum, wrong length)
- ✓ EAN-8 validation (valid, invalid checksum)
- ✓ UPC-A validation
- ✓ Format detection (Code-128, Code-39, QR)
- ✓ General validation (empty, whitespace, invalid chars)
- ✓ Whitespace stripping

**How to run:**
```bash
flutter test test/scanner_services_test.dart
```

**Expected output:**
```
✓ All barcode format tests pass
✓ Checksum validation works correctly
✓ Format detection accurate
✓ Invalid inputs rejected
```

---

## 2. `scanner_integration_test.dart`

**Purpose:** Integration tests for complete scanner workflow

**Coverage:**
- ✓ Barcode detection & validation
- ✓ Product lookup (found/not found)
- ✓ Deduplication & cooldown logic
- ✓ Auto-add to cart
- ✓ Cart total calculation
- ✓ Error handling (network, invalid format, timeout)
- ✓ Performance benchmarks
- ✓ Event system

**How to run:**
```bash
flutter test test/scanner_integration_test.dart
```

**Expected output:**
```
✓ Product detection works
✓ Deduplication prevents duplicates
✓ Cart management correct
✓ Errors handled gracefully
✓ Performance within limits
✓ All events emitted
```

---

# Running All Tests

## Run everything:
```bash
flutter test test/
```

## Run with coverage:
```bash
flutter test --coverage
```

## Run specific test:
```bash
flutter test test/scanner_services_test.dart -k "EAN-13"
```

## Run with verbose output:
```bash
flutter test -v
```

---

# Test Scenarios

## Scenario 1: Valid Barcode Scan
```
Input: "5901234123457" (EAN-13)
↓
Validation: ✓ Valid format, ✓ Valid checksum
↓
Product Lookup: Found (Aspirin, €12.50)
↓
Auto-Add: Added to cart (qty: 1)
↓
Result: ✓ PASS
```

## Scenario 2: Invalid Barcode
```
Input: "INVALID!!!" (Non-numeric)
↓
Validation: ✗ Invalid format, ✗ Invalid chars
↓
Result: ✗ Rejected (no product lookup)
```

## Scenario 3: Duplicate Detection
```
Scan 1: "5901234123457" at t=0ms
↓
Scan 2: "5901234123457" at t=100ms (< 150ms cooldown)
↓
Result: ✗ Blocked (deduplication)
```

## Scenario 4: Cart Management
```
Scan: "5901234123457" → Add Aspirin (qty: 1)
Scan: "1234567890123" → Add Ibuprofen (qty: 1)
Scan: "5901234123457" → Increment Aspirin (qty: 1 → 2)
↓
Result: [Aspirin x2, Ibuprofen x1] ✓ PASS
```

## Scenario 5: Product Not Found
```
Input: "9999999999999" (Valid format but no product)
↓
Product Lookup: ✗ Not found in database
↓
Action: Emit ProductNotFound event
↓
UI: Show ProductNotFoundDialog
↓
Result: ✓ Error handled correctly
```

---

# Performance Benchmarks

| Metric | Target | Status |
|--------|--------|--------|
| Barcode validation | < 10ms | ✓ |
| Product lookup | < 300ms | ✓ |
| Total scan → cart | < 310ms | ✓ |
| 5 rapid scans | < 1000ms | ✓ |
| 1000 scans memory | No leak | ✓ |

---

# Troubleshooting

## Test fails: "Package not found"
```bash
flutter pub get
flutter pub upgrade
```

## Test fails: "Build failed"
```bash
flutter clean
flutter pub get
flutter test
```

## Test hangs (timeout)
- Increase timeout in test setup
- Check for infinite loops in implementation
- Verify async operations complete

---

# Continuous Integration

Add to GitHub Actions / CI pipeline:

```yaml
- name: Run tests
  run: |
    flutter test
    flutter test --coverage

- name: Upload coverage
  run: |
    # Upload to codecov or similar
    bash <(curl -s https://codecov.io/bash)
```

---

# Test Maintenance

## When to update tests:
- [ ] New barcode format supported
- [ ] API changes
- [ ] New event types
- [ ] Performance improvements
- [ ] Bug fixes

## Test naming convention:
```dart
test('Should [action] when [condition]', () {
  // Given
  // When
  // Then
  expect(...);
});
```

---

# Coverage Goals

- [ ] Barcode detection: 95%+
- [ ] Event system: 90%+
- [ ] Auto-cart logic: 85%+
- [ ] Error handling: 80%+
- **Overall: 85%+**

---

# Related Files

- [SCANNER_INTEGRATION_GUIDE.md](../SCANNER_INTEGRATION_GUIDE.md) - Main documentation
- [lib/scanner/services/](../lib/scanner/services/) - Source code
- [lib/scanner/widgets/](../lib/scanner/widgets/) - Widget code
- [lib/ventes/services/auto_cart_manager.dart](../lib/ventes/services/auto_cart_manager.dart) - Cart logic

---

Created: 2024
Version: 1.0
Status: ✅ TEST SUITE COMPLETE
