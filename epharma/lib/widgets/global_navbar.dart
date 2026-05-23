//import 'package:epharma/activites/activity_register_page.dart';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'bp_theme.dart';
import '../settings/settings_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'brand_title.dart';
import 'notification_panel.dart';

// =====================================================================
// GLOBAL NAVBAR WIDGET
// =====================================================================

class GlobalNavbar extends StatefulWidget {
  final VoidCallback onMenuToggle;
  final bool isSidebarOpen;
  final Function(String)? onProfileAction;
  final Function(String, dynamic)? onNotificationNavigate;

  const GlobalNavbar({
    required this.onMenuToggle,
    required this.isSidebarOpen,
    this.onProfileAction,
    this.onNotificationNavigate,
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
            color: BpColors.glass,
            border: Border(
              bottom: BorderSide(color: BpColors.border.withOpacity(0.9)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                    color: BpColors.accent,
                    size: 26,
                  ),
                  onPressed: widget.onMenuToggle,
                ),
              ),

              // ===== CENTER SECTION: LOGO / BRANDING =====
              Expanded(
                child: Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (!isVerySmall) ...[
                      Flexible(
                        child: BrandTitle(
                          title: 'BigPharma',
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
                      Builder(
                        builder: (context) {
                          final unreadCount = context
                              .watch<NotificationProvider>()
                              .unreadCount;
                          return IconButton(
                            icon: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: BpColors.textSecondary,
                                  size: 22,
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: kDangerRed,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Text(
                                      unreadCount > 9
                                          ? '9+'
                                          : unreadCount.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () {
                              _showNotificationPanel(context);
                            },
                          );
                        },
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
                      itemBuilder: (BuildContext context) =>
                          _buildProfileItems(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: BpColors.borderStrong,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: BpColors.accent.withOpacity(0.15),
                              child: const Icon(
                                Icons.person,
                                color: BpColors.accent,
                                size: 20,
                              ),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    context
                                            .watch<AuthProvider>()
                                            .user
                                            ?.fullName ??
                                        'Utilisateur',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: BpColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    (context.watch<AuthProvider>().user?.role ??
                                            'PHARMACIEN')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: BpColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: BpColors.textSecondary,
                                size: 18,
                              ),
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
            Text("Journal d'activite"),
          ],
        ),
      ),
      if (context.read<AuthProvider>().user?.role != 'client')
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings, color: kAccentBlue, size: 20),
              SizedBox(width: 12),
              Text('Parametres'),
            ],
          ),
        ),
      PopupMenuItem<String>(
        value: 'test-notification',
        child: Row(
          children: const [
            Icon(Icons.notifications_active, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Text('Tester notification'),
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
            Text('Deconnexion', style: TextStyle(color: kDangerRed)),
          ],
        ),
      ),
    ];
  }

  void _handleProfileAction(String action) {
    switch (action) {
      case 'profile':
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
        break;

      case 'activity':
        AppScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ouverture du journal d'activite")),
        );
        break;
      case 'settings':
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
        break;
      case 'test-notification':
        _testNotification();
        break;
      case 'help':
        AppScaffoldMessenger.of(context).showSnackBar(
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

  void _testNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test de Notification'),
        content: const Text('Envoi d\'une notification de test...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context
                    .read<NotificationProvider>()
                    .sendTestNotification();
                if (context.mounted) {
                  Navigator.pop(context);
                  AppScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('[OK] Notification de test envoyee!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('[ERREUR] $e'),
                      backgroundColor: kDangerRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Envoyer', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Etes-vous sur de vouloir vous deconnecter ?'),
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
              'Deconnecter',
              style: TextStyle(color: kDangerRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationPanel(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Position the panel below the notification icon
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          Offset(button.size.width - 350, 70),
          ancestor: overlay,
        ),
        button.localToGlobal(Offset(button.size.width, 70), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 70, // Height of navbar
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: NotificationPanel(
                onTap: (type, data) {
                  Navigator.pop(context); // Close dialog
                  widget.onNotificationNavigate?.call(type, data);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
