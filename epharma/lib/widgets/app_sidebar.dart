import 'package:flutter/material.dart';
import 'app_colors.dart';

typedef SidebarCallbacks = Map<String, VoidCallback>;

class AppSidebar extends StatelessWidget {
  final String? selectedLabel;
  final SidebarCallbacks? callbacks;

  const AppSidebar({super.key, this.selectedLabel, this.callbacks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryGreen,
                  child: Icon(Icons.medical_services, color: Colors.white),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'BigPharma',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                AppSidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  selected: selectedLabel == 'Dashboard',
                  onTap: callbacks?['Dashboard'],
                ),
                AppSidebarItem(
                  icon: Icons.inventory_2,
                  label: 'Stock',
                  selected: selectedLabel == 'Stock',
                  onTap: callbacks?['Stock'],
                ),
                AppSidebarItem(
                  icon: Icons.receipt_long,
                  label: 'Sales',
                  selected: selectedLabel == 'Sales',
                  onTap: callbacks?['Sales'],
                ),
                AppSidebarItem(
                  icon: Icons.people,
                  label: 'Clients',
                  selected: selectedLabel == 'Clients',
                  onTap: callbacks?['Clients'],
                ),
                AppSidebarItem(
                  icon: Icons.local_pharmacy,
                  label: 'Journal d\'activités',
                  selected: selectedLabel == 'Activity',
                  onTap: callbacks?['Activity'],
                ),
                AppSidebarItem(
                  icon: Icons.medical_services,
                  label: 'Consultations',
                  selected: selectedLabel == 'Consultations',
                  onTap: callbacks?['Consultations'],
                ),
                AppSidebarItem(
                  icon: Icons.report,
                  label: 'Finances',
                  selected: selectedLabel == 'Finances',
                  onTap: callbacks?['Finances'],
                ),
                AppSidebarItem(
                  icon: Icons.business,
                  label: 'Fournisseurs',
                  selected: selectedLabel == 'Fournisseurs',
                  onTap: callbacks?['Fournisseurs'],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: selected ? kSoftBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: selected ? kPrimaryGreen : Colors.grey[700]),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: selected ? Colors.black : Colors.grey[800],
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
