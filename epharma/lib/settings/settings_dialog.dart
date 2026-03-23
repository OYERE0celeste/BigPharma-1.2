import 'package:epharma/settings/profil_dialog.dart';
import 'package:epharma/settings/user_management_page.dart';
//import 'package:epharma/settings/securite_dialog.dart';
//import 'package:epharma/settings/gestion_donnees_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRole;

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

    if (provider.availableRoles.contains(settings.role)) {
      _selectedRole = settings.role;
    } else {
      _selectedRole = provider.availableRoles.isNotEmpty
          ? provider.availableRoles.first
          : null;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? kDangerRed : kPrimaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Key for internal navigation
  final GlobalKey<NavigatorState> _settingsNavKey = GlobalKey<NavigatorState>();
  bool _canGoBack = false;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (Intent intent) => Navigator.of(context, rootNavigator: true).pop(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 24,
            clipBehavior: Clip.antiAlias,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SettingsTheme.dialogMaxWidth,
                maxHeight: SettingsTheme.dialogMaxHeight,
              ),
              child: Container(
                color: SettingsTheme.background,
                child: Column(
                  children: [
                    _buildAnimatedHeader(context),
                    Expanded(
                      child: Navigator(
                        key: _settingsNavKey,
                        initialRoute: 'main',
                        onGenerateRoute: (settings) {
                          Widget page;
                          switch (settings.name) {
                            case 'profile':
                              page = const ProfilDialog();
                              break;
                            case 'users':
                              page = const UserManagementDialog();
                              break;
                            case 'main':
                            default:
                              page = _buildMainSettingsList(context);
                              break;
                          }
                          return _createSlideRoute(page, settings.name!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return Container(
      height: SettingsTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: SettingsTheme.divider)),
      ),
      child: Row(
        children: [
          // Dynamic Back Button
          if (_canGoBack)
            IconButton(
              onPressed: () {
                _settingsNavKey.currentState?.pop();
                setState(() => _canGoBack = _settingsNavKey.currentState?.canPop() ?? false);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SettingsTheme.primary, size: 20),
              splashRadius: 24,
            )
          else
            const SizedBox(width: 8),
          
          const Icon(Icons.settings, color: SettingsTheme.primary, size: 28),
          const SizedBox(width: 16),
          const Text(
            'Paramètres Système',
            style: SettingsTheme.headerTitle,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: const Icon(Icons.close, color: SettingsTheme.textSecondary),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Route _createSlideRoute(Widget page, String name) {
    return PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = SettingsTheme.animationCurve;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: SettingsTheme.animationDuration,
    );
  }

  // Update navigation tile to trigger state change for header
  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _settingsNavKey.currentState?.pushNamed(routeName).then((_) {
            if (mounted) {
              setState(() => _canGoBack = _settingsNavKey.currentState?.canPop() ?? false);
            }
          });
          setState(() => _canGoBack = true);
        },
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
              const Icon(Icons.chevron_right_rounded, color: SettingsTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // Update Main Settings List to use the updated tile
  Widget _buildMainSettingsList(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSummary(provider),
                  const SizedBox(height: 32),
                  const Text("PRÉFÉRENCES ET SÉCURITÉ", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SettingsTheme.textSecondary, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  _buildNavigationTile(
                    icon: Icons.person_outline_rounded,
                    title: "Mon profil",
                    subtitle: "Informations personnelles et compte",
                    routeName: 'profile',
                  ),
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
                    routeName: 'profile',
                  ),
                  _buildNavigationTile(
                    icon: Icons.data_usage_rounded,
                    title: "Gestion des données",
                    subtitle: "Sauvegarde, export et nettoyage",
                    routeName: 'profile',
                  ),
                ],
              ),
            ),
            if (provider.isLoading)
              Container(
                color: Colors.white.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: SettingsTheme.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSummary(SettingsProvider provider) {
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
            backgroundImage: provider.settings.profileImageUrl.isNotEmpty
                ? NetworkImage(provider.settings.profileImageUrl)
                : null,
            child: provider.settings.profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: SettingsTheme.primary)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.settings.fullName, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SettingsTheme.textPrimary)),
                Text(provider.settings.email, 
                  style: const TextStyle(fontSize: 14, color: SettingsTheme.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SettingsTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(provider.settings.role.toUpperCase(), 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // End of Navigation Methods

  // End of Navigation Methods

  // Layout Helpers

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kPrimaryGreen),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildRoleDropdown(SettingsProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rôle',
        prefixIcon: Icon(Icons.work_outline, color: Colors.grey[600], size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(12),
      ),
      items: provider.availableRoles.map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedRole = value),
    );
  }

  Widget _buildPasswordChangeButton() {
    return OutlinedButton.icon(
      onPressed: () => _showChangePasswordDialog(),
      icon: const Icon(Icons.lock_outline, size: 18),
      label: const Text('Mot de passe'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: kPrimaryGreen,
        side: const BorderSide(color: kPrimaryGreen),
      ),
    );
  }

  Widget _buildSaveProfileButton(SettingsProvider provider) {
    return ElevatedButton.icon(
      onPressed: provider.isLoading ? null : () => _saveProfile(provider),
      icon: const Icon(Icons.save, size: 18),
      label: const Text('Sauvegarder'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
    );
  }

  Widget _buildPermissionsSection(SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôles & Permissions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: provider.settings.permissions.entries.map((entry) {
            return FilterChip(
              label: Text(entry.key, style: const TextStyle(fontSize: 12)),
              selected: entry.value,
              onSelected: (value) =>
                  _updatePermission(provider, entry.key, value),
              selectedColor: kSoftBlue,
              checkmarkColor: kPrimaryGreen,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTwoFactorSection(SettingsProvider provider) {
    return SwitchListTile(
      title: const Text(
        'Authentification à deux facteurs',
        style: TextStyle(fontSize: 14),
      ),
      subtitle: const Text(
        'Sécurité renforcée pour votre compte',
        style: TextStyle(fontSize: 12),
      ),
      value: provider.settings.twoFactorEnabled,
      onChanged: (value) => _toggleTwoFactor(provider, value),
      activeColor: kPrimaryGreen,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLoginHistorySection(SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dernières connexions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.settings.loginHistory.length > 3
              ? 3
              : provider.settings.loginHistory.length,
          separatorBuilder: (_, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final history = provider.settings.loginHistory[index];
            return ListTile(
              leading: Icon(
                history.success ? Icons.check_circle : Icons.error,
                color: history.success ? kPrimaryGreen : kDangerRed,
                size: 16,
              ),
              title: Text(history.device, style: const TextStyle(fontSize: 13)),
              subtitle: Text(
                history.date.toString().substring(0, 16),
                style: const TextStyle(fontSize: 11),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackupSection(SettingsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _backupData(provider),
            icon: const Icon(Icons.backup, size: 18),
            label: const Text('Sauvegarder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _restoreData(provider),
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('Restaurer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryGreen,
              side: const BorderSide(color: kPrimaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportImportSection(SettingsProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportData(provider, 'json'),
                icon: const Icon(Icons.code, size: 18),
                label: const Text('Export JSON'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportData(provider, 'csv'),
                icon: const Icon(Icons.table_chart, size: 18),
                label: const Text('Export CSV'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _importData(provider),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Importer un fichier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kWarningOrange,
              side: const BorderSide(color: kWarningOrange),
            ),
          ),
        ),
      ],
    );
  }

  // Dialogs and Actions
  void _showChangeProfileImageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Photo de profil'),
        content: const Text('Fonctionnalité de téléchargement simulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ancien mot de passe',
              ),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
              ),
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
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Mot de passe mis à jour !');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(SettingsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await provider.updateProfile(
      fullName: _fullNameController.text,
      email: _emailController.text,
      role: _selectedRole ?? '',
    );
    if (success) _showSnackBar('Profil mis à jour');
  }

  void _updatePermission(
    SettingsProvider provider,
    String key,
    bool value,
  ) async {
    final success = await provider.updatePermission(key, value);
    if (success) {
      _showSnackBar('Permission "$key" mise à jour');
    } else {
      _showSnackBar('Erreur lors de la mise à jour', isError: true);
    }
  }

  void _toggleTwoFactor(SettingsProvider provider, bool value) async {
    final success = await provider.toggleTwoFactor(value);
    if (success) {
      _showSnackBar(value ? '2FA activé' : '2FA désactivé');
    } else {
      _showSnackBar('Erreur lors de la mise à jour', isError: true);
    }
  }

  void _backupData(SettingsProvider provider) async {
    final success = await provider.backupData();
    if (success) {
      _showSnackBar('Sauvegarde effectuée avec succès');
    } else {
      _showSnackBar('Échec de la sauvegarde', isError: true);
    }
  }

  void _restoreData(SettingsProvider provider) async {
    // Dans un vrai cas, on ouvrirait un sélecteur de fichier
    final success = await provider.restoreData('mock_path.bak');
    if (success) {
      _showSnackBar('Données restaurées avec succès');
    } else {
      _showSnackBar('Échec de la restauration', isError: true);
    }
  }

  void _exportData(SettingsProvider provider, String format) async {
    final success = await provider.exportData(format);
    if (success) {
      _showSnackBar('Exportation $format terminée');
    } else {
      _showSnackBar('Échec de l\'exportation', isError: true);
    }
  }

  void _importData(SettingsProvider provider) async {
    final success = await provider.importData('mock_path.json');
    if (success) {
      _showSnackBar('Données importées avec succès');
    } else {
      _showSnackBar('Échec de l\'importation', isError: true);
    }
  }
}
