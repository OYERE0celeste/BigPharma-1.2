import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import 'package:epharma/providers/settings_provider.dart';
import 'package:epharma/providers/auth_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/bp_theme.dart';
import 'settings_theme.dart';
import 'profil_dialog.dart';
import 'user_management_page.dart';
import 'securite_dialog.dart';
import 'gestion_donnees_dialog.dart';
import 'appearance_settings.dart';

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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _currentView = 'main';
  final List<String> _viewHistory = ['main'];
  bool _isGoingBack = false;

  void _navigateTo(String view) {
    setState(() {
      _viewHistory.add(view);
      _currentView = view;
      _isGoingBack = false;
    });
  }

  void _navigateBack() {
    if (_viewHistory.length > 1) {
      setState(() {
        _viewHistory.removeLast();
        _currentView = _viewHistory.last;
        _isGoingBack = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings().then((_) {
        if (mounted) {
          _initializeFields();
        }
      });
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    final provider = context.read<SettingsProvider>();
    final settings = provider.settings;
    _fullNameController.text = settings.fullName;
    _emailController.text = settings.email;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    AppScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? kDangerRed : kPrimaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
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
                  child: AnimatedSwitcher(
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
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey(_currentView),
                      color: SettingsTheme.background,
                      child: _buildBody(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return AlertDialog(
        title: const Text("Erreur d'affichage"),
        content: Text(
          "Une erreur est survenue lors de l'ouverture des paramètres: $e",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      );
    }
  }

  Widget _buildBody() {
    switch (_currentView) {
      case 'profile':
        return const ProfilDialog();
      case 'users':
        return const UserManagementDialog();
      case 'security':
        return const SecuriteDialog();
      case 'data':
        return const GestionDonneesDialog();
      case 'appearance':
        return const AppearanceSettings();
      default:
        return _buildMainSettingsList(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final role = provider.settings.role.toString();
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
              onPressed: _navigateBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: SettingsTheme.primary,
                size: 20,
              ),
              splashRadius: 24,
            )
          else
            const SizedBox(width: 8),

          Icon(Icons.settings, color: SettingsTheme.primary, size: 28),
          const SizedBox(width: 16),
          Text(
            role == 'client' ? 'Paramètres' : 'Paramètres Système',
            style: SettingsTheme.headerTitle,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: SettingsTheme.textSecondary),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateTo(routeName),
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
                  color: SettingsTheme.accent.withOpacity(0.3),
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

  Widget _buildMainSettingsList(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        final authUser = context.watch<AuthProvider>().user;
        final canManageUsers = authUser?.can('manage_users') ?? false;
        final canManageSettings = authUser?.can('manage_settings') ?? false;
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSummary(provider),
                  SizedBox(height: 32),
                  Text(
                    "PRÉFÉRENCES ET SÉCURITÉ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SettingsTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildNavigationTile(
                    icon: Icons.person_outline_rounded,
                    title: "Mon profil",
                    subtitle: "Informations personnelles et compte",
                    routeName: 'profile',
                  ),
                  if (canManageUsers)
                    _buildNavigationTile(
                      icon: Icons.people_outline_rounded,
                      title: "Gestion des collaborateurs",
                      subtitle: "Gérez votre équipe et les accès",
                      routeName: 'users',
                    ),
                  _buildNavigationTile(
                    icon: Icons.security_outlined,
                    title: "Sécurité",
                    subtitle: "Mot de passe et authentification",
                    routeName: 'security',
                  ),
                  if (canManageSettings)
                    _buildNavigationTile(
                      icon: Icons.data_usage_rounded,
                      title: "Gestion des données",
                      subtitle: "Sauvegarde, export et nettoyage",
                      routeName: 'data',
                    ),
                  _buildNavigationTile(
                    icon: Icons.palette_outlined,
                    title: "Apparence",
                    subtitle: "Palette et mode sombre",
                    routeName: 'appearance',
                  ),
                ],
              ),
            ),
            if (provider.isLoading)
              Container(
                color: BpColors.scaffold.withOpacity(0.42),
                child: Center(
                  child: CircularProgressIndicator(
                    color: SettingsTheme.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSummary(SettingsProvider provider) {
    final authUser = context.watch<AuthProvider>().user;
    final name = provider.settings.fullName.isNotEmpty
        ? provider.settings.fullName
        : authUser?.fullName ?? 'Utilisateur';
    final email = provider.settings.email.isNotEmpty
        ? provider.settings.email
        : authUser?.email ?? '';

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
            backgroundImage: provider.settings.profileImageUrl.isNotEmpty
                ? NetworkImage(provider.settings.profileImageUrl)
                : null,
            child: provider.settings.profileImageUrl.isEmpty
                ? Icon(Icons.person, size: 30, color: SettingsTheme.primary)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SettingsTheme.textPrimary,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: SettingsTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SettingsTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    provider.settings.role.toUpperCase(),
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
  }
}
