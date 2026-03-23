import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
//import 'app_colors.dart';

typedef SidebarCallbacks = Map<String, VoidCallback>;

class AppSidebar extends StatelessWidget {
  final String? selectedLabel;
  final SidebarCallbacks? callbacks;

  const AppSidebar({super.key, this.selectedLabel, this.callbacks});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    return Container(
      width: 240, // Slightly wider for premium look
      color: const Color(0xFFF8FAFC), // Very light gray background
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
                  backgroundColor: Color(0xFF6366F1), // Indigo Logo
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
                _sidebarItem('Dashboard', Icons.grid_view_rounded),
                _sidebarItem('Stock', Icons.inventory_2_outlined),
                _sidebarItem('Sales', Icons.receipt_long_outlined),
                _sidebarItem('Clients', Icons.people_outline_rounded),
                _sidebarItem('Commandes', Icons.shopping_cart_outlined),
                _sidebarItem('Fournisseurs', Icons.business_outlined),
                _sidebarItem('Finances', Icons.account_balance_wallet_outlined),
                /*_sidebarItem(
                  'Activity',
                  Icons.history_rounded,
                  label: "Journal d'activités",
                ),*/

                /*if (isAdmin) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 14, top: 20, bottom: 8),
                    child: Text("ADMINISTRATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.0)),
                  ),
                  _sidebarItem('Users', Icons.manage_accounts_outlined, label: "Gestion Utilisateurs"),
                ],
                
                const Divider(height: 40, color: Colors.black12, indent: 8, endIndent: 8),
                _sidebarItem('Paramètres', Icons.settings_outlined),*/
              ],
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppSidebarItem(
              icon: Icons.logout_rounded,
              label: 'Déconnexion',
              color: Colors.redAccent.withOpacity(0.8),
              onTap: () => authProvider.logout(),
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
