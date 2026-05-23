import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'notification_accessibility.dart';

enum AppNotificationType { success, error, warning, info }

enum AppNotificationPlacement { adaptive, banner, toast }

class AppNotificationAction {
  const AppNotificationAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class AppNotificationService {
  AppNotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final _AppNotificationController _controller =
      _AppNotificationController();

  static void show(
    String message, {
    AppNotificationType type = AppNotificationType.info,
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    AppNotificationAction? action,
    Duration? duration,
    bool persistent = false,
  }) {
    final trimmedMessage = _sanitizeMessage(message);
    if (trimmedMessage.isEmpty) {
      return;
    }

    final resolvedPersistent =
        persistent || _isCriticalNotification(type, trimmedMessage);
    final resolvedPlacement = placement == AppNotificationPlacement.adaptive
        ? _resolvePlacement(type)
        : placement;

    final entry = _AppNotificationEntry(
      id: _controller.nextId(),
      message: trimmedMessage,
      type: type,
      placement: resolvedPlacement,
      action: action,
      duration: duration ?? const Duration(seconds: 5),
      persistent: resolvedPersistent,
    );

    _controller.show(entry);
    _announce(entry);
  }

  static void showSuccess(
    String message, {
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    AppNotificationAction? action,
    Duration? duration,
  }) {
    show(
      message,
      type: AppNotificationType.success,
      placement: placement,
      action: action,
      duration: duration,
    );
  }

  static void showError(
    String message, {
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    AppNotificationAction? action,
    Duration? duration,
    bool persistent = false,
  }) {
    show(
      message,
      type: AppNotificationType.error,
      placement: placement,
      action: action,
      duration: duration,
      persistent: persistent,
    );
  }

  static void showWarning(
    String message, {
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    AppNotificationAction? action,
    Duration? duration,
  }) {
    show(
      message,
      type: AppNotificationType.warning,
      placement: placement,
      action: action,
      duration: duration,
    );
  }

  static void showInfo(
    String message, {
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    AppNotificationAction? action,
    Duration? duration,
  }) {
    show(
      message,
      type: AppNotificationType.info,
      placement: placement,
      action: action,
      duration: duration,
    );
  }

  static void showSnackBar(
    BuildContext context,
    SnackBar snackBar, {
    AppNotificationType? type,
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    bool persistent = false,
  }) {
    final message = _extractMessage(snackBar.content);
    if (message.isEmpty) {
      return;
    }

    show(
      message,
      type: type ?? _inferType(snackBar, message),
      placement: placement,
      action: snackBar.action == null
          ? null
          : AppNotificationAction(
              label: snackBar.action!.label,
              onPressed: snackBar.action!.onPressed,
            ),
      persistent: persistent,
    );
  }

  static void dismiss(String id) {
    _controller.dismiss(id);
  }

  static void dismissAll() {
    _controller.dismissAll();
  }

  static void _announce(_AppNotificationEntry entry) {
    final context = navigatorKey.currentContext;
    final textDirection = context != null
        ? Directionality.maybeOf(context) ?? TextDirection.ltr
        : TextDirection.ltr;
    final semanticsMessage =
        '${entry.type.accessibilityLabel}. ${entry.message}';

    SemanticsService.announce(semanticsMessage, textDirection);
    announceAriaAlert(semanticsMessage);
  }

  static AppNotificationPlacement _resolvePlacement(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.error:
      case AppNotificationType.warning:
        return AppNotificationPlacement.banner;
      case AppNotificationType.success:
      case AppNotificationType.info:
        return AppNotificationPlacement.toast;
    }
  }

  static String _sanitizeMessage(String message) {
    var cleaned = message.trim();
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring('Exception: '.length).trim();
    }

    final structuredMessage = RegExp(
      r'message:\s*([^,}]+)',
      caseSensitive: false,
    ).firstMatch(cleaned);

    if (cleaned.startsWith('{') &&
        cleaned.endsWith('}') &&
        structuredMessage != null) {
      cleaned = structuredMessage.group(1)?.trim() ?? cleaned;
    }

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return _localizeMessage(cleaned);
  }

  static String _localizeMessage(String message) {
    final normalized = _normalizeMessage(message);

    if (normalized.contains('email is already taken') ||
        normalized.contains('email already exists')) {
      return 'Cet e-mail est deja utilise.';
    }
    if (normalized.contains('email is required')) {
      return "L'e-mail est requis.";
    }

    return message;
  }

  static String _extractMessage(Widget content) {
    if (content is Text) {
      return content.data ?? content.textSpan?.toPlainText() ?? '';
    }

    return content.toStringShort();
  }

  static AppNotificationType _inferType(SnackBar snackBar, String message) {
    final backgroundColor = snackBar.backgroundColor;
    if (backgroundColor != null) {
      if (backgroundColor.red > 210 &&
          backgroundColor.green < 120 &&
          backgroundColor.blue < 120) {
        return AppNotificationType.error;
      }
      if (backgroundColor.red > 230 &&
          backgroundColor.green > 160 &&
          backgroundColor.blue < 120) {
        return AppNotificationType.warning;
      }
      if (backgroundColor.green > 140 &&
          backgroundColor.red < 140 &&
          backgroundColor.blue < 170) {
        return AppNotificationType.success;
      }
      if (backgroundColor.blue > 170 && backgroundColor.red < 120) {
        return AppNotificationType.info;
      }
    }

    final normalized = _normalizeMessage(message);
    if (_containsAny(normalized, const [
      'succes',
      'reussi',
      'ajout',
      'cree',
      'mis a jour',
      'envoye',
      'effectue',
      'supprime',
      'reactive',
      'desactive',
      'valide',
    ])) {
      return AppNotificationType.success;
    }
    if (_containsAny(normalized, const [
      'erreur',
      'echec',
      'impossible',
      'refus',
      'incorrect',
      'invalide',
      'bloque',
    ])) {
      return AppNotificationType.error;
    }
    if (_containsAny(normalized, const [
      'veuillez',
      'verifiez',
      'attention',
      'insuffisant',
      'vide',
      'rupture',
      'future',
      'ouverture',
    ])) {
      return AppNotificationType.warning;
    }

    return AppNotificationType.info;
  }

  static bool _isCriticalNotification(
    AppNotificationType type,
    String message,
  ) {
    if (type != AppNotificationType.error) {
      return false;
    }

    final normalized = _normalizeMessage(message);
    return normalized.contains('critique') ||
        normalized.contains('critical') ||
        normalized.contains('fatal');
  }

  static bool _containsAny(String message, List<String> needles) {
    return needles.any(message.contains);
  }

  static String _normalizeMessage(String message) {
    var normalized = message.toLowerCase();
    const replacements = <String, String>{
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ì': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ò': 'o',
      'ó': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
    };

    replacements.forEach((source, target) {
      normalized = normalized.replaceAll(source, target);
    });

    return normalized;
  }
}

class AppScaffoldMessenger {
  const AppScaffoldMessenger._(this.context);

  final BuildContext context;

  static AppScaffoldMessenger of(BuildContext context) {
    return AppScaffoldMessenger._(context);
  }

  void showSnackBar(
    SnackBar snackBar, {
    AppNotificationType? type,
    AppNotificationPlacement placement = AppNotificationPlacement.adaptive,
    bool persistent = false,
  }) {
    AppNotificationService.showSnackBar(
      context,
      snackBar,
      type: type,
      placement: placement,
      persistent: persistent,
    );
  }

  void hideCurrentSnackBar() {
    AppNotificationService.dismissAll();
  }
}

class AppNotificationHost extends StatelessWidget {
  const AppNotificationHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppNotificationService._controller,
      child: child,
      builder: (context, child) {
        final entries = AppNotificationService._controller.entries;
        final banners = entries
            .where(
              (entry) => entry.placement == AppNotificationPlacement.banner,
            )
            .toList(growable: false);
        final toasts = entries
            .where((entry) => entry.placement == AppNotificationPlacement.toast)
            .toList(growable: false);
        final isWideLayout = MediaQuery.sizeOf(context).width >= 920;
        final safeChild = child ?? const SizedBox.shrink();

        return Stack(
          children: [
            Positioned.fill(child: safeChild),
            if (banners.isNotEmpty)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final entry in banners)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AppNotificationCard(
                                entry: entry,
                                isWideLayout: isWideLayout,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (toasts.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  minimum: EdgeInsets.fromLTRB(
                    16,
                    0,
                    isWideLayout ? 24 : 16,
                    20,
                  ),
                  child: Align(
                    alignment: isWideLayout
                        ? Alignment.bottomRight
                        : Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideLayout ? 420 : 560,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isWideLayout
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.stretch,
                        children: [
                          for (final entry in toasts.reversed)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _AppNotificationCard(
                                entry: entry,
                                isWideLayout: isWideLayout,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AppNotificationController extends ChangeNotifier {
  final List<_AppNotificationEntry> _entries = <_AppNotificationEntry>[];
  int _sequence = 0;

  List<_AppNotificationEntry> get entries => List.unmodifiable(_entries);

  String nextId() => 'app-notification-${_sequence++}';

  void show(_AppNotificationEntry entry) {
    _entries.insert(0, entry);
    if (!entry.persistent) {
      entry.dismissTimer = Timer(entry.duration, () => dismiss(entry.id));
    }
    if (_entries.length > 4) {
      final overflowEntry = _entries.removeLast();
      overflowEntry.dismissTimer?.cancel();
    }
    notifyListeners();
  }

  void dismiss(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }

    final entry = _entries[index];
    if (!entry.isVisible) {
      return;
    }

    entry.dismissTimer?.cancel();
    entry.isVisible = false;
    notifyListeners();

    Timer(const Duration(milliseconds: 220), () {
      _entries.removeWhere((candidate) => candidate.id == id);
      notifyListeners();
    });
  }

  void dismissAll() {
    final ids = _entries.map((entry) => entry.id).toList(growable: false);
    for (final id in ids) {
      dismiss(id);
    }
  }
}

class _AppNotificationEntry {
  _AppNotificationEntry({
    required this.id,
    required this.message,
    required this.type,
    required this.placement,
    required this.duration,
    required this.persistent,
    this.action,
  });

  final String id;
  final String message;
  final AppNotificationType type;
  final AppNotificationPlacement placement;
  final Duration duration;
  final bool persistent;
  final AppNotificationAction? action;
  bool isVisible = true;
  Timer? dismissTimer;
}

class _AppNotificationCard extends StatelessWidget {
  const _AppNotificationCard({required this.entry, required this.isWideLayout});

  final _AppNotificationEntry entry;
  final bool isWideLayout;

  @override
  Widget build(BuildContext context) {
    final palette = _NotificationPalette.fromType(entry.type);
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF122033),
      fontWeight: FontWeight.w600,
      height: 1.35,
    );
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: palette.foreground,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );
    final actionStyle = theme.textTheme.labelLarge?.copyWith(
      color: palette.baseColor,
      fontWeight: FontWeight.w700,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      opacity: entry.isVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: entry.isVisible
            ? Offset.zero
            : entry.placement == AppNotificationPlacement.banner
            ? const Offset(0, -0.12)
            : const Offset(0.14, 0),
        child: Semantics(
          container: true,
          liveRegion: true,
          label: '${entry.type.accessibilityLabel}: ${entry.message}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.softBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        palette.symbol,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.type.label, style: labelStyle),
                          const SizedBox(height: 4),
                          Text(entry.message, style: bodyStyle),
                          if (entry.action != null) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                AppNotificationService.dismiss(entry.id);
                                entry.action!.onPressed();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: palette.baseColor,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                entry.action!.label,
                                style: actionStyle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => AppNotificationService.dismiss(entry.id),
                      splashRadius: 18,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        size: isWideLayout ? 18 : 20,
                        color: const Color(0xFF5A6573),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationPalette {
  const _NotificationPalette({
    required this.baseColor,
    required this.softBackground,
    required this.borderColor,
    required this.foreground,
    required this.symbol,
  });

  final Color baseColor;
  final Color softBackground;
  final Color borderColor;
  final Color foreground;
  final String symbol;

  static _NotificationPalette fromType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return const _NotificationPalette(
          baseColor: Color(0xFF4CAF50),
          softBackground: Color(0xFFEAF7EC),
          borderColor: Color(0xFFBFE2C1),
          foreground: Color(0xFF215B25),
          symbol: '[OK]',
        );
      case AppNotificationType.error:
        return const _NotificationPalette(
          baseColor: Color(0xFFF44336),
          softBackground: Color(0xFFFFECEA),
          borderColor: Color(0xFFF3B6B1),
          foreground: Color(0xFF8A1D15),
          symbol: '[X]',
        );
      case AppNotificationType.warning:
        return const _NotificationPalette(
          baseColor: Color(0xFFFFC107),
          softBackground: Color(0xFFFFF7E1),
          borderColor: Color(0xFFF2DB93),
          foreground: Color(0xFF6A5200),
          symbol: '[!]',
        );
      case AppNotificationType.info:
        return const _NotificationPalette(
          baseColor: Color(0xFF2196F3),
          softBackground: Color(0xFFEAF4FE),
          borderColor: Color(0xFFB8D8F4),
          foreground: Color(0xFF0E4C7A),
          symbol: '[i]',
        );
    }
  }
}

extension AppNotificationTypeLabels on AppNotificationType {
  String get label {
    switch (this) {
      case AppNotificationType.success:
        return 'Succes';
      case AppNotificationType.error:
        return 'Erreur';
      case AppNotificationType.warning:
        return 'Avertissement';
      case AppNotificationType.info:
        return 'Information';
    }
  }

  String get accessibilityLabel {
    switch (this) {
      case AppNotificationType.success:
        return 'Notification de succes';
      case AppNotificationType.error:
        return "Notification d'erreur";
      case AppNotificationType.warning:
        return "Notification d'avertissement";
      case AppNotificationType.info:
        return "Notification d'information";
    }
  }
}
