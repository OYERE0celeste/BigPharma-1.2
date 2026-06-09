import 'package:flutter/material.dart';
import '../bp_theme.dart';

/// AppSection: small helper to create titled sections with consistent spacing.
class AppSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BpTextStyles.heading3),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
