import 'package:flutter/material.dart';
import 'package:client_app/constants/strings.dart';
import 'bp_theme.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({
    super.key,
    this.title = AppStrings.appName,
    this.badge,
    this.subtitle,
  });

  final String title;
  final String? badge;
  final String? subtitle;

  static const Gradient _brandGradient = LinearGradient(
    colors: [BpColors.accent, Color(0xFFA6F1CB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                foreground: Paint()
                  ..shader = _brandGradient.createShader(
                    const Rect.fromLTWH(0, 0, 260, 80),
                  ),
              ),
            ),
            if (badge != null && badge!.isNotEmpty) ...[
              const SizedBox(width: 10),
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
                  style: const TextStyle(
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
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.75),
            ),
          ),
        ],
      ],
    );
  }
}
