import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_provider.dart';
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
  final GlobalKey<NavigatorState> _settingsNavKey = GlobalKey<NavigatorState>();
  bool _canGoBack = false;

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
                child: Navigator(
                  key: _settingsNavKey,
                  initialRoute: 'main',
                  onGenerateRoute: (settings) {
                    Widget page;
                    switch (settings.name) {
                      case 'profile':
                        page = const ClientProfileView();
                        break;
                      case 'security':
                        page = const ClientSecurityView();
                        break;
                      case 'main':
                      default:
                        page = _buildMainList(context);
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: SettingsTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: SettingsTheme.divider)),
      ),
      child: Row(
        children: [
          if (_canGoBack)
            IconButton(
              onPressed: () {
                _settingsNavKey.currentState?.pop();
                setState(() => _canGoBack = _settingsNavKey.currentState?.canPop() ?? false);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SettingsTheme.primary, size: 20),
            )
          else
            const SizedBox(width: 8),
          const Icon(Icons.settings_rounded, color: SettingsTheme.primary, size: 28),
          const SizedBox(width: 16),
          const Text('Paramètres', style: SettingsTheme.headerTitle),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: SettingsTheme.textSecondary),
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
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: SettingsTheme.animationDuration,
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
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final name = profile?['fullName'] ?? 'Client';
        final email = profile?['email'] ?? '';
        
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
                child: const Icon(Icons.person, size: 30, color: SettingsTheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SettingsTheme.textPrimary)),
                    Text(email, style: const TextStyle(fontSize: 14, color: SettingsTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: SettingsTheme.primary, borderRadius: BorderRadius.circular(4)),
                      child: const Text('CLIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildNavTile({required IconData icon, required String title, required String subtitle, required String routeName}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _settingsNavKey.currentState?.pushNamed(routeName).then((_) {
            if (mounted) setState(() => _canGoBack = _settingsNavKey.currentState?.canPop() ?? false);
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
                decoration: BoxDecoration(color: SettingsTheme.accent, borderRadius: BorderRadius.circular(10)),
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
}

class ClientProfileView extends StatefulWidget {
  const ClientProfileView({super.key});

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<ClientProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?['fullName'] ?? '');
    _phoneController = TextEditingController(text: profile?['phone'] ?? '');
    _addressController = TextEditingController(text: profile?['address'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informations Personnelles", style: SettingsTheme.sectionTitle),
            const SizedBox(height: 24),
            _buildField(_nameController, "Nom complet", Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_phoneController, "Téléphone", Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildField(_addressController, "Adresse", Icons.location_on_outlined),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _save,
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                label: const Text("Enregistrer les modifications"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22, color: SettingsTheme.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.primary, width: 2)),
      ),
    );
  }

  void _save() async {
    final success = await context.read<ProfileProvider>().updateProfile({
      'fullName': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour avec succès')));
    }
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
            onTap: () {},
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

  Widget _buildSecurityTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
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
}
