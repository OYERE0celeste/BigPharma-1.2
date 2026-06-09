import 'package:flutter/material.dart';
import '../bp_theme.dart';

/// AppCard: thin wrapper around `BpSurfaceCard` to standardize section cards.
class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.padding,
    this.margin,
    this.radius = BpSpacing.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      radius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || (actions != null && actions!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (title != null)
                    Expanded(child: Text(title!, style: BpTextStyles.heading3)),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}
