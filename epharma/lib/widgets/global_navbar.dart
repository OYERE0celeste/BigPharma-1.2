//import 'package:epharma/activites/activity_register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import '../settings/settings_dialog.dart';
import '../providers/auth_provider.dart';

// =====================================================================
// GLOBAL NAVBAR WIDGET
// =====================================================================

class GlobalNavbar extends StatefulWidget {
  final VoidCallback onMenuToggle;
  final bool isSidebarOpen;
  final Function(String)? onProfileAction;

  const GlobalNavbar({
    required this.onMenuToggle,
    required this.isSidebarOpen,
    this.onProfileAction,
    super.key,
  });

  @override
  State<GlobalNavbar> createState() => _GlobalNavbarState();
}

class _GlobalNavbarState extends State<GlobalNavbar> {
  late GlobalKey<PopupMenuButtonState<String>> _profileMenuKey;

  @override
  void initState() {
    super.initState();
    _profileMenuKey = GlobalKey<PopupMenuButtonState<String>>();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isVerySmall = constraints.maxWidth < 400;

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ===== LEFT SECTION: HAMBURGER MENU =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(
                    widget.isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: kPrimaryGreen,
                    size: 26,
                  ),
                  onPressed: widget.onMenuToggle,
                ),
              ),

              // ===== CENTER SECTION: LOGO / BRANDING =====
              Expanded(
                child: Row(
                  mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kPrimaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (!isVerySmall) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.watch<AuthProvider>().company?.name ?? 'PharmaGest',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen,
                              ),
                            ),
                            if (!isMobile)
                              Text(
                                'Professional Pharmacy Manager',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ===== RIGHT SECTION: PROFILE MENU & STATUS =====
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    if (!isVerySmall)
                      IconButton(
                        icon: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 22),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: kDangerRed, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),

                    const SizedBox(width: 4),

                    // User profile menu
                    PopupMenuButton<String>(
                      key: _profileMenuKey,
                      position: PopupMenuPosition.under,
                      onSelected: (value) {
                        widget.onProfileAction?.call(value);
                        _handleProfileAction(value);
                      },
                      itemBuilder: (BuildContext context) => _buildProfileItems(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: kPrimaryGreen.withOpacity(0.1),
                              child: const Icon(Icons.person, color: kPrimaryGreen, size: 20),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    context.watch<AuthProvider>().user?.fullName ?? 'Utilisateur',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    context.watch<AuthProvider>().user?.role.toUpperCase() ?? 'PHARMACIEN',
                                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildProfileItems() {
    return [
      PopupMenuItem<String>(
        value: 'profile',
        child: Row(
          children: const [
            Icon(Icons.account_circle, color: kPrimaryGreen, size: 20),
            SizedBox(width: 12),
            Text('Mon Profil'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'activity',
        child: Row(
          children: const [
            Icon(Icons.history_rounded, color: kPrimaryGreen, size: 20),
            SizedBox(width: 12),
            Text("Journal d'activité"),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'settings',
        child: Row(
          children: const [
            Icon(Icons.settings, color: kAccentBlue, size: 20),
            SizedBox(width: 12),
            Text('Paramètres'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: const [
            Icon(Icons.logout, color: kDangerRed, size: 20),
            SizedBox(width: 12),
            Text('Déconnexion', style: TextStyle(color: kDangerRed)),
          ],
        ),
      ),
    ];
  }
}

  void _handleProfileAction(String action) {
    switch (action) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers Mon Profil')),
        );
        break;
      case 'activity':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ouverture du journal d'activité")),
        );
        break;
      case 'settings':
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
        break;
      case 'help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ouverture Aide & Support')),
        );
        break;
      case 'logout':
        _showLogoutDialog();
        break;
      default:
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: kDangerRed),
            ),
          ),
        ],
      ),
    );
  }
}
