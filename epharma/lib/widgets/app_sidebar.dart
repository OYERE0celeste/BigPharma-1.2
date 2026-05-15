import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../security/rbac.dart';

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
      return user.canAny(entry.permissions);
    }).toList();

    final adminKeys = {'Finances', 'Rights', 'Users', 'Activity'};
    final primaryEntries = visibleEntries
        .where((entry) => !adminKeys.contains(entry.key))
        .toList();
    final adminEntries = visibleEntries
        .where((entry) => adminKeys.contains(entry.key))
        .toList();

    return Container(
      width: 240,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF6366F1),
                  child: Icon(
                    Icons.local_pharmacy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.company?.name ?? 'BigPharma',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'SaaS Edition',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...primaryEntries.map(
                  (entry) =>
                      _sidebarItem(entry.key, entry.icon, label: entry.label),
                ),
                if (adminEntries.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 14, top: 20, bottom: 8),
                    child: Text(
                      'ADMINISTRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  ...adminEntries.map(
                    (entry) =>
                        _sidebarItem(entry.key, entry.icon, label: entry.label),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    final activeColor = color ?? const Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: selected ? activeColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? activeColor
                      : (color ?? const Color(0xFF475569)),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? activeColor
                          : (color ?? const Color(0xFF475569)),
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
