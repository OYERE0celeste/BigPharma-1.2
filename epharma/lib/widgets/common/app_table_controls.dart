import 'package:flutter/material.dart';

import '../bp_theme.dart';
import 'app_ui.dart';

class AppTableRowsPerPageSelector extends StatelessWidget {
  const AppTableRowsPerPageSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const [10, 20, 50],
    this.label = 'Lignes par page',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final List<int> options;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: BpColors.surfaceMuted,
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: BpColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isDense: true,
              icon: Icon(Icons.expand_more, size: 18),
              iconEnabledColor: BpColors.textSecondary,
              dropdownColor: BpColors.surface,
              style: TextStyle(
                color: BpColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<int>(
                      value: option,
                      child: Text('$option'),
                    ),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppTablePager extends StatelessWidget {
  const AppTablePager({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.pageLabelBuilder,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String Function(int currentPage, int totalPages)? pageLabelBuilder;

  String get _pageLabel {
    final safePageIndex = totalPages <= 1
        ? 0
        : currentPage.clamp(0, totalPages - 1).toInt();
    return pageLabelBuilder?.call(safePageIndex, totalPages) ??
        'Page ${safePageIndex + 1} sur $totalPages';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: BpColors.surfaceMuted,
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        border: Border.all(color: BpColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Page précédente',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            iconSize: 18,
            icon: Icon(Icons.chevron_left, color: BpColors.textPrimary),
            onPressed: currentPage > 0 ? onPrevious : null,
          ),
          Text(
            _pageLabel,
            style: TextStyle(
              color: BpColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            tooltip: 'Page suivante',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            iconSize: 18,
            icon: Icon(Icons.chevron_right, color: BpColors.textPrimary),
            onPressed: (currentPage + 1) < totalPages ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class AppTableFooter extends StatelessWidget {
  const AppTableFooter({
    super.key,
    required this.summary,
    required this.pager,
    this.leading,
    this.padding = const EdgeInsets.all(16),
    this.compactBreakpoint = AppResponsive.tabletBreakpoint,
  });

  final String summary;
  final Widget pager;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < compactBreakpoint;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  summary,
                  style: TextStyle(
                    color: BpColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (leading != null) ...[
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: leading!),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: pager,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  summary,
                  style: TextStyle(
                    color: BpColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              pager,
            ],
          );
        },
      ),
    );
  }
}
