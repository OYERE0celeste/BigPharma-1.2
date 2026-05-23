import 'package:flutter/foundation.dart';
import '../models/scan_result_model.dart';

/// 🔄 Service for managing scan cache and preventing duplicate scans
///
/// Implements:
/// - LRU cache (keeps last 50 scans)
/// - Cooldown mechanism (prevents re-scanning same code within 500ms)
/// - Efficient deduplication
/// - Cache statistics
class ScanCacheService {
  /// Maximum cache size
  static const int maxCacheSize = 50;

  /// Minimum time between same scans (anti-bounce)
  static const Duration cooldownDuration = Duration(milliseconds: 500);

  /// Cache storage: code -> CachedScan
  final Map<String, CachedScan> _cache = {};

  /// LRU list to track access order
  final List<String> _lruList = [];

  /// Statistics
  int _totalScans = 0;
  int _cacheHits = 0;
  int _duplicatesFiltered = 0;

  /// Check if code is in cache and valid (within cooldown)
  bool isCached(String code) {
    final cached = _cache[code];
    if (cached == null) return false;
    return cached.isValid(cooldownDuration);
  }

  /// Try to add scan to cache
  /// Returns true if scan is NEW (not in cooldown), false if DUPLICATE
  bool canScan(String code) {
    _totalScans++;

    final cached = _cache[code];

    // Cache miss - new scan
    if (cached == null) {
      return true;
    }

    // Check cooldown
    if (!cached.isValid(cooldownDuration)) {
      // Cooldown expired - allow new scan
      _cache.remove(code);
      return true;
    }

    // In cooldown - duplicate scan
    _duplicatesFiltered++;
    cached.scanCount++;
    _updateLRU(code);

    return false;
  }

  /// Add scan to cache
  void addScan(ScanResult scan) {
    final code = scan.rawValue;

    final cachedScan = CachedScan(
      scan: scan,
      cachedAt: DateTime.now(),
      scanCount: 1,
    );

    _cache[code] = cachedScan;
    _updateLRU(code);
    _evictIfNeeded();

    debugPrint('✅ Scan cached: $code');
  }

  /// Get scan from cache
  CachedScan? getScan(String code) {
    final cached = _cache[code];
    if (cached != null) {
      _cacheHits++;
      _updateLRU(code);
    }
    return cached;
  }

  /// Update LRU list (move to end = most recently used)
  void _updateLRU(String code) {
    _lruList.remove(code);
    _lruList.add(code);
  }

  /// Evict least recently used item if cache is full
  void _evictIfNeeded() {
    if (_cache.length > maxCacheSize && _lruList.isNotEmpty) {
      final lru = _lruList.removeAt(0);
      _cache.remove(lru);
      debugPrint('🗑️ Cache evicted (LRU): $lru');
    }
  }

  /// Clear entire cache
  void clear() {
    _cache.clear();
    _lruList.clear();
    debugPrint('🗑️ Scan cache cleared');
  }

  /// Clear old entries (older than duration)
  void clearOlderThan(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);

    _cache.removeWhere((code, cached) {
      final isOld = cached.cachedAt.isBefore(cutoff);
      if (isOld) {
        _lruList.remove(code);
      }
      return isOld;
    });

    debugPrint('🧹 Cache cleaned: removed entries older than $duration');
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'totalScans': _totalScans,
      'cacheSize': _cache.length,
      'cacheHits': _cacheHits,
      'duplicatesFiltered': _duplicatesFiltered,
      'hitRate': _totalScans == 0
          ? 0
          : '${(_cacheHits * 100 / _totalScans).toStringAsFixed(1)}%',
      'duplicateRate': _totalScans == 0
          ? 0
          : '${(_duplicatesFiltered * 100 / _totalScans).toStringAsFixed(1)}%',
    };
  }

  /// Get cached scans list (for UI display)
  List<CachedScan> getCachedScans() {
    return _cache.values.toList()
      ..sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
  }

  /// Export cache as JSON for debugging/logging
  List<Map<String, dynamic>> exportAsJson() {
    return getCachedScans()
        .map(
          (cached) => {
            'code': cached.scan.rawValue,
            'type': cached.scan.codeType,
            'scanCount': cached.scanCount,
            'cachedAt': cached.cachedAt.toIso8601String(),
            'confidence': cached.scan.confidence,
          },
        )
        .toList();
  }
}
