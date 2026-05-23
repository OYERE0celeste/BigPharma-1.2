// 📡 Scanner Event Bus
//
// Global pub-sub event system for scanner events.
// Allows any page/service to subscribe to scan events and react.
//
// Event Flow:
// GlobalKeyboardScannerService -> ScannerEventBus.emit()
//                              -> All subscribers notified
//                              -> Pages react accordingly

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';

// ============================================================================
// EVENT DEFINITIONS
// ============================================================================

/// Base class for all scanner events
abstract class ScanEvent {
  const ScanEvent();
}

/// 📱 Raw barcode detected from keyboard/scanner
///
/// Emitted immediately when barcode buffer is complete (ENTER pressed).
/// Product lookup happens asynchronously after this event.
class ScanDetected extends ScanEvent {
  final String barcode;
  final DateTime timestamp;

  ScanDetected(this.barcode, {DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ScanDetected($barcode at ${timestamp.toIso8601String()})';
}

/// ✓ Product found in database after barcode lookup
///
/// Emitted when product is successfully found.
/// Pages should handle ProductFound event to determine action based on context.
class ProductFound extends ScanEvent {
  final Product product;
  final String barcode;
  final DateTime timestamp;

  ProductFound(this.product, this.barcode, {DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ProductFound(${product.name} / $barcode at ${timestamp.toIso8601String()})';
}

/// ✗ Product NOT found after barcode lookup
///
/// Emitted when barcode doesn't match any product in database.
/// Pages should offer product creation or show error.
class ProductNotFound extends ScanEvent {
  final String barcode;
  final DateTime timestamp;

  ProductNotFound(this.barcode, {DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ProductNotFound($barcode at ${timestamp.toIso8601String()})';
}

/// 🛒 Product successfully added to cart
///
/// Emitted by AutoCartManager when product is added/incremented in cart.
/// Used for UI feedback (animation, notification, etc).
class ProductAddedToCart extends ScanEvent {
  final Product product;
  final int newQuantity;
  final bool wasAlreadyInCart;
  final DateTime timestamp;

  ProductAddedToCart(
    this.product,
    this.newQuantity, {
    this.wasAlreadyInCart = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ProductAddedToCart(${product.name} x$newQuantity${wasAlreadyInCart ? ' (incremented)' : ''} at ${timestamp.toIso8601String()})';
}

/// ⚠️ Scan error occurred
///
/// Emitted when:
/// - Validation failed
/// - Product lookup error
/// - Network error
/// - Duplicate scan during cooldown
class ScanError extends ScanEvent {
  final String message;
  final String? barcode;
  final DateTime timestamp;

  ScanError(this.message, {this.barcode, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ScanError($message / $barcode at ${timestamp.toIso8601String()})';
}

/// ⏱️ Scanner in cooldown (anti-double-scan protection)
///
/// Emitted when duplicate scan detected within cooldown period.
/// Informs UI to temporarily disable scanning.
class ScanCooldown extends ScanEvent {
  final String barcode;
  final int remainingMs;
  final DateTime timestamp;

  ScanCooldown(this.barcode, this.remainingMs, {DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ScanCooldown($barcode - ${remainingMs}ms remaining at ${timestamp.toIso8601String()})';
}

// ============================================================================
// EVENT BUS
// ============================================================================

/// 📡 Global event bus for scanner events
///
/// Singleton pattern - use ScannerEventBus.instance
///
/// Usage:
/// ```dart
/// // Subscribe to events
/// ScannerEventBus.instance.on<ProductFound>().listen((event) {
///   print('Product found: ${event.product.name}');
/// });
///
/// // Emit events
/// ScannerEventBus.instance.emit(ProductFound(product, barcode));
/// ```
class ScannerEventBus {
  static final ScannerEventBus _instance = ScannerEventBus._internal();

  factory ScannerEventBus() {
    return _instance;
  }

  static ScannerEventBus get instance => _instance;

  ScannerEventBus._internal();

  /// Event streams for each event type
  /// Using `Map<Type, Stream>` pattern for dynamic event handling
  final Map<Type, List<_EventHandler>> _handlers = {};

  /// Emit an event to all subscribers
  ///
  /// Notifies all listeners subscribed to this event type.
  /// Events are processed synchronously (use Future for async handling).
  void emit(ScanEvent event) {
    debugPrint('📡 ScannerEventBus: Emitting ${event.runtimeType}');

    final eventType = event.runtimeType;
    final handlers = _handlers[eventType];

    if (handlers != null) {
      for (final handler in handlers.toList()) {
        try {
          handler.callback(event);
        } catch (e) {
          debugPrint('❌ Error in event handler: $e');
        }
      }
    }
  }

  /// Subscribe to specific event type
  ///
  /// Returns a stream of events for this type.
  /// Common usage:
  /// ```dart
  /// bus.on<ProductFound>().listen((event) {
  ///   // Handle ProductFound event
  /// });
  /// ```
  ScannerEventStream<T> on<T extends ScanEvent>() {
    return ScannerEventStream<T>(this);
  }

  /// Internal: Register event handler
  void _subscribe<T extends ScanEvent>(Function callback) {
    final eventType = T;
    _handlers.putIfAbsent(eventType, () => []);
    _handlers[eventType]!.add(_EventHandler<T>(callback));
  }

  /// Internal: Remove event handler
  void _unsubscribe<T extends ScanEvent>(_EventHandler<T> handler) {
    final eventType = T;
    _handlers[eventType]?.remove(handler);
  }

  /// Clear all event handlers (use with caution)
  void clearAllHandlers() {
    _handlers.clear();
  }

  /// Get count of handlers for specific event type
  int handlerCount<T extends ScanEvent>() {
    return _handlers[T]?.length ?? 0;
  }

  /// Get total handler count
  int get totalHandlers =>
      _handlers.values.fold(0, (sum, list) => sum + list.length);
}

// ============================================================================
// INTERNAL STREAM IMPLEMENTATION
// ============================================================================

/// Internal: Event handler wrapper
class _EventHandler<T extends ScanEvent> {
  final Function callback;

  _EventHandler(this.callback);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EventHandler &&
          runtimeType == other.runtimeType &&
          callback == other.callback;

  @override
  int get hashCode => callback.hashCode;
}

/// Internal: Event stream for type-safe listening
class ScannerEventStream<T extends ScanEvent> {
  final ScannerEventBus _bus;

  ScannerEventStream(this._bus);

  /// Listen to events of this type
  StreamSubscription<T> listen(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _EventStreamSubscription<T>(
      _bus,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }
}

/// Internal: Subscription to event stream
class _EventStreamSubscription<T extends ScanEvent>
    implements StreamSubscription<T> {
  final ScannerEventBus _bus;
  final void Function(T event) _onData;
  final Function? _onError;
  void Function()? _onDone;
  final bool _cancelOnError;
  bool _closed = false;

  late final _EventHandler<T> _handler;

  _EventStreamSubscription(
    this._bus,
    this._onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) : _onError = onError,
       _onDone = onDone,
       _cancelOnError = cancelOnError {
    _handler = _EventHandler<T>((event) {
      if (!_closed) {
        try {
          _onData(event as T);
        } catch (e) {
          if (_onError != null) {
            _onError(e);
            if (_cancelOnError) cancel();
          }
        }
      }
    });

    _bus._subscribe<T>(_handler.callback);
  }

  @override
  Future<void> cancel() async {
    if (!_closed) {
      _closed = true;
      _bus._unsubscribe<T>(_handler);
      _onDone?.call();
    }
  }

  @override
  void onData(void Function(T event)? handleData) {
    // Not implemented - use listen() instead
  }

  @override
  void onDone(void Function()? handleDone) {
    _onDone = handleDone;
  }

  @override
  void onError(Function? handleError) {
    // Not implemented in this simplified version
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) {
    throw UnimplementedError('asFuture not implemented');
  }

  @override
  bool get isPaused => false;

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}
}
