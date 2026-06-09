import 'package:flutter/material.dart';

import 'common/app_ui.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget desktop;
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    required this.mobile,
    this.tablet,
  });

  static bool isMobile(BuildContext context) =>
      AppResponsive.isMobile(context);
  static bool isTablet(BuildContext context) =>
      AppResponsive.isTablet(context);
  static bool isDesktop(BuildContext context) =>
      AppResponsive.isDesktop(context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
