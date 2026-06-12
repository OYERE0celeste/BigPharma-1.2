import 'package:flutter/material.dart';

import 'bp_theme.dart';

class DetailSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const DetailSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        border: Border.all(color: BpColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BpTextStyles.heading3),
          const SizedBox(height: 6),
          Text(subtitle, style: BpTextStyles.caption),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class DetailInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: BpColors.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: BpColors.accent, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BpTextStyles.caption),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BpColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  const DetailMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface.withOpacity(0.65),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tone.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tone, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BpTextStyles.caption),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BpColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  const DetailPill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
