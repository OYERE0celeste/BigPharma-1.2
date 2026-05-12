import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'profile_view.dart';
import 'settings_theme.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String _currentView = 'main';

  @override
  void initState() {
    super.initState();
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
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentView) {
      case 'profile':
        return const ProfileView(isInsideDialog: true);
      case 'security':
        return const ClientSecurityView();
      default:
        return _buildMainList(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final canGoBack = _currentView != 'main';
    return Container(
      height: SettingsTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: SettingsTheme.divider)),
      ),
      child: Row(
        children: [
          if (canGoBack)
            IconButton(
              onPressed: () => setState(() => _currentView = 'main'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          const SizedBox(width: 8),
          Text(
            _currentView == 'profile'
                ? 'Mon Profil'
                : _currentView == 'security'
                    ? 'Sécurité'
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
          const Text(
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
            color: SettingsTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SettingsTheme.primary.withOpacity(0.1)),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SettingsTheme.textPrimary,
                      ),
                    ),
                    Text(
                      displayEmail,
                      style: const TextStyle(
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
    required String routeName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _currentView = routeName),
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
              const Icon(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sécurité", style: SettingsTheme.sectionTitle),
          const SizedBox(height: 24),
          _buildSecurityTile(
            icon: Icons.lock_outline_rounded,
            title: "Changer le mot de passe",
            subtitle: "Mettez à jour votre mot de passe régulièrement",
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          _buildSecurityTile(
            icon: Icons.phonelink_lock_rounded,
            title: "Double authentification (2FA)",
            subtitle: "Ajoutez une couche de sécurité supplémentaire",
            onTap: () {},
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SettingsTheme.divider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: SettingsTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
              decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer'),
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
                ScaffoldMessenger.of(context).showSnackBar(
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
