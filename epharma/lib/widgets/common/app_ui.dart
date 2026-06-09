import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bp_theme.dart';

class AppResponsive {
  AppResponsive._();

  static const double mobileBreakpoint = 720;
  static const double tabletBreakpoint = 1080;

  static double widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => widthOf(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = widthOf(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) => widthOf(context) >= tabletBreakpoint;

  static EdgeInsets pagePadding(
    BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    final width = widthOf(context);
    final horizontal = width < mobileBreakpoint
        ? mobile
        : width < tabletBreakpoint
            ? tablet
            : desktop;
    return EdgeInsets.all(horizontal);
  }

  static EdgeInsets horizontalPadding(
    BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    final width = widthOf(context);
    final horizontal = width < mobileBreakpoint
        ? mobile
        : width < tabletBreakpoint
            ? tablet
            : desktop;
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static EdgeInsets dialogInset(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isMobile(context) ? 12 : 24,
      vertical: isMobile(context) ? 12 : 32,
    );
  }

  static int gridColumns(
    double width, {
    double minTileWidth = 240,
    int maxColumns = 6,
  }) {
    return math.max(1, math.min(maxColumns, (width / minTileWidth).floor()));
  }
}

class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.maxHeight = 800,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.radius = BpSpacing.radiusXl,
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppResponsive.dialogInset(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: BpSurfaceCard(
          padding: EdgeInsets.zero,
          radius: radius,
          color: backgroundColor,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppTableShell extends StatelessWidget {
  const AppTableShell({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(0),
    this.margin,
    this.radius = BpSpacing.radiusXl,
    this.backgroundColor,
  });

  final Widget child;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      margin: margin,
      padding: EdgeInsets.zero,
      radius: radius,
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Padding(padding: padding, child: child),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class AppContentShell extends StatelessWidget {
  const AppContentShell({
    super.key,
    required this.child,
    this.maxWidth = 1680,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final body = SizedBox(width: double.infinity, child: child);

    if (AppResponsive.isMobile(context)) {
      return body;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: body,
      ),
    );
  }
}
