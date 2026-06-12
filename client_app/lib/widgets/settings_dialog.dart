import 'package:flutter/material.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'bp_theme.dart';
import 'profile_view.dart';
import 'settings_theme.dart';
import '../pages/invoices_page.dart';
import 'appearance_settings.dart';

class SettingsDialog extends StatefulWidget {
  final String initialView;
  const SettingsDialog({super.key, this.initialView = 'main'});

  static void show(BuildContext context, {String initialView = 'main'}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SettingsDialog(initialView: initialView),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String _currentView;
  late final List<String> _history;
  bool _isGoingBack = false;

  void _navigateTo(String view) {
    setState(() {
      _isGoingBack = false;
      _history.add(view);
      _currentView = view;
    });
  }

  void _goBack() {
    if (_history.length > 1) {
      setState(() {
        _isGoingBack = true;
        _history.removeLast();
        _currentView = _history.last;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
    _history = [widget.initialView];
    Future.microtask(() {
      context.read<AuthProvider>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 24,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: SettingsTheme.dialogMaxWidth,
          maxHeight: SettingsTheme.dialogMaxHeight,
        ),
        child: Container(
          color: SettingsTheme.background,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isEntering = child.key == ValueKey(_currentView);
        Offset beginOffset;
        if (_isGoingBack) {
          beginOffset = isEntering
              ? const Offset(-1.0, 0.0)
              : const Offset(1.0, 0.0);
        } else {
          beginOffset = isEntering
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0);
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(_currentView),
        child: _buildCurrentViewContent(),
      ),
    );
  }

  Widget _buildCurrentViewContent() {
    switch (_currentView) {
      case 'profile':
        return const ProfileView(isInsideDialog: true);
      case 'security':
        return const ClientSecurityView();
      case 'invoices':
        return const InvoicesView();
      case 'appearance':
        return const AppearanceSettings();
      default:
        return _buildMainList(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final canGoBack = _currentView != 'main';
    return Container(
      height: SettingsTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SettingsTheme.background,
        border: Border(bottom: BorderSide(color: SettingsTheme.divider)),
      ),
      child: Row(
        children: [
          if (canGoBack)
            IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          const SizedBox(width: 8),
          Text(
            _currentView == 'profile'
                ? 'Mon Profil'
                : _currentView == 'security'
                ? 'Sécurité'
                : _currentView == 'invoices'
                ? 'Historique factures'
                : _currentView == 'appearance'
                ? 'Apparence'
                : 'Paramètres',
            style: SettingsTheme.headerTitle,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMainList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSummary(),
          const SizedBox(height: 32),
          Text(
            "MON COMPTE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SettingsTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildNavTile(
            icon: Icons.person_outline_rounded,
            title: "Mon profil",
            subtitle: "Modifier vos informations personnelles",
            routeName: 'profile',
          ),
          _buildNavTile(
            icon: Icons.security_outlined,
            title: "Sécurité",
            subtitle: "Mot de passe et authentification",
            routeName: 'security',
          ),
          _buildNavTile(
            icon: Icons.receipt_long_outlined,
            title: "Historique factures",
            subtitle: "Consulter vos factures d'achat",
            routeName: 'invoices',
          ),
          const SizedBox(height: 32),
          Text(
            "PRÉFÉRENCES",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SettingsTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildNavTile(
            icon: Icons.palette_outlined,
            title: "Apparence",
            subtitle: "Couleurs et thème de l'application",
            routeName: 'appearance',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final displayName = user?.fullName ?? 'Client';
        final displayEmail = user?.email ?? '';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SettingsTheme.accent.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SettingsTheme.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: SettingsTheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: SettingsTheme.primary.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SettingsTheme.textPrimary,
                      ),
                    ),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: SettingsTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SettingsTheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'CLIENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? routeName,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap ?? () => _navigateTo(routeName!),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: SettingsTheme.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SettingsTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: SettingsTheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: SettingsTheme.sectionTitle),
                    Text(subtitle, style: SettingsTheme.bodyText),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: SettingsTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientSecurityView extends StatelessWidget {
  const ClientSecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Shield Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SettingsTheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: SettingsTheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sécurité du compte",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: SettingsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gérez vos informations d'accès et protégez vos transactions.",
                  style: TextStyle(
                    fontSize: 12,
                    color: SettingsTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Grouped security tiles in a single premium card
          Container(
            decoration: BoxDecoration(
              color: SettingsTheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SettingsTheme.divider),
            ),
            child: Column(
              children: [
                _buildSecurityTile(
                  icon: Icons.lock_outline_rounded,
                  title: "Changer le mot de passe",
                  subtitle: "Mettez à jour votre mot de passe régulièrement",
                  onTap: () => _showChangePasswordDialog(context),
                ),
                Divider(height: 1, color: SettingsTheme.divider, indent: 64),
                _buildSecurityTile(
                  icon: Icons.phonelink_lock_rounded,
                  title: "Double authentification (2FA)",
                  subtitle: "Ajoutez une couche de sécurité supplémentaire",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SettingsTheme.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: SettingsTheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: SettingsTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: SettingsTheme.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: SettingsTheme.textSecondary,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Changer de mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: BpInputTheme.dark(
                label: 'Mot de passe actuel',
                hint: 'Mot de passe actuel',
                showLabel: false,
              ),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: BpInputTheme.dark(
                label: 'Nouveau mot de passe',
                hint: 'Nouveau mot de passe',
                showLabel: false,
              ),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: BpInputTheme.dark(
                label: 'Confirmer',
                hint: 'Confirmer',
                showLabel: false,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AuthProvider>().changePassword(
                currentPassword: currentCtrl.text,
                newPassword: newCtrl.text,
                confirmPassword: confirmCtrl.text,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                AppScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success']
                          ? 'Mot de passe modifié'
                          : result['message'] ?? 'Erreur',
                    ),
                  ),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}
