/// 📱 Result from a barcode/QR code scan
class ScanResult {
  /// The raw code value detected
  final String rawValue;

  /// Type of code detected: 'barcode', 'qrcode', 'auto'
  final String codeType;

  /// Timestamp when scan was detected
  final DateTime timestamp;

  /// Confidence level (0-1) if available
  final double? confidence;

  /// Additional metadata from detection
  final Map<String, dynamic>? metadata;

  ScanResult({
    required this.rawValue,
    required this.codeType,
    required this.timestamp,
    this.confidence,
    this.metadata,
  });

  @override
  String toString() =>
      'ScanResult(value: $rawValue, type: $codeType, time: ${timestamp.toIso8601String()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResult &&
          runtimeType == other.runtimeType &&
          rawValue == other.rawValue &&
          codeType == other.codeType;

  @override
  int get hashCode => rawValue.hashCode ^ codeType.hashCode;
}

/// 📊 Cached scan entry with metadata
class CachedScan {
  /// The scan result
  final ScanResult scan;

  /// When this scan was cached
  final DateTime cachedAt;

  /// How many times this code was scanned
  int scanCount;

  CachedScan({required this.scan, required this.cachedAt, this.scanCount = 1});

  /// Check if scan is still valid (within cooldown period)
  bool isValid(Duration cooldown) {
    return DateTime.now().difference(cachedAt) < cooldown;
  }
}

/// 📈 Scanner session statistics
class ScannerStats {
  /// Total scans in this session
  int totalScans = 0;

  /// Successful products found
  int successCount = 0;

  /// Products not found
  int notFoundCount = 0;

  /// Duplicate scans filtered out
  int duplicateCount = 0;

  /// Session start time
  final DateTime startTime = DateTime.now();

  void incrementSuccess() => successCount++;
  void incrementNotFound() => notFoundCount++;
  void incrementDuplicate() => duplicateCount++;

  int get successRate =>
      totalScans == 0 ? 0 : (successCount * 100 ~/ totalScans);

  Duration get sessionDuration => DateTime.now().difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'totalScans': totalScans,
      'successCount': successCount,
      'notFoundCount': notFoundCount,
      'duplicateCount': duplicateCount,
      'successRate': '$successRate%',
      'sessionDuration': sessionDuration.inSeconds,
    };
  }
}
