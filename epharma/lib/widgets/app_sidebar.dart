import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../security/rbac.dart';
import 'bp_theme.dart';
import 'brand_title.dart';

typedef SidebarCallbacks = Map<String, VoidCallback>;

class AppSidebar extends StatelessWidget {
  final String? selectedLabel;
  final SidebarCallbacks? callbacks;

  const AppSidebar({super.key, this.selectedLabel, this.callbacks});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final visibleEntries = kSidebarEntries.where((entry) {
      if (user == null) return false;
      return entry.showInSidebar && user.canAny(entry.permissions);
    }).toList();

    return Container(
      width: 240,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: BpSurfaceCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        radius: 28,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Flexible(
                    child: BrandTitle(
                      title: 'BigPharma',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  ...visibleEntries.map(
                    (entry) =>
                        _sidebarItem(entry.key, entry.icon, label: entry.label),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(String key, IconData icon, {String? label}) {
    return AppSidebarItem(
      icon: icon,
      label: label ?? key,
      selected: selectedLabel == key,
      onTap: callbacks?[key],
    );
  }
}

class AppSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const AppSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? BpColors.accent;
    final inactiveColor = color ?? BpColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? BpColors.accent.withOpacity(0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? Border.all(color: BpColors.borderStrong)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? activeColor : inactiveColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? activeColor : inactiveColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
