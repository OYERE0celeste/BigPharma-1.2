import 'package:flutter/material.dart';
import 'bp_theme.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({
    super.key,
    this.title = 'BigPharma',
    this.badge,
    this.subtitle,
    this.style,
    this.iconColor,
  });

  final String title;
  final String? badge;
  final String? subtitle;
  final TextStyle? style;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      color: BpColors.textPrimary,
    );

    final textStyle = style ?? defaultStyle;
    final fontSize = textStyle.fontSize ?? 24.0;
    // L'icône est légèrement plus grande que le texte
    final finalIconSize = fontSize * 1.25;
    final finalIconColor = iconColor ?? textStyle.color ?? BpColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: finalIconSize, color: finalIconColor),
            SizedBox(width: 8),
            Text(title, style: textStyle),
            if (badge != null && badge!.isNotEmpty) ...[
              SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: BpColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BpColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: BpColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
