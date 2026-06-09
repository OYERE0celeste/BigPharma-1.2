import 'package:flutter/material.dart';
import 'bp_theme.dart';
import 'common/app_ui.dart';

class PageStatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const PageStatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class PageStatCards extends StatelessWidget {
  final List<PageStatCardData> items;

  const PageStatCards({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = items.isEmpty
            ? 1
            : items.length < AppResponsive.gridColumns(width)
                ? items.length
                : AppResponsive.gridColumns(width);
        final childAspectRatio = width < 600 ? 1.8 : 2.15;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => _PageStatCard(item: items[index]),
        );
      },
    );
  }
}

class _PageStatCard extends StatelessWidget {
  final PageStatCardData item;

  const _PageStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: BpSpacing.radiusLg,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BpColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BpColors.textPrimary,
                    ),
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
