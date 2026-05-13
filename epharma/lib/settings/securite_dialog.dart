import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'settings_theme.dart';
import '../widgets/app_colors.dart';
import 'user_management_page.dart';
import 'rights_management_page.dart';

class SecuriteDialog extends StatefulWidget {
  const SecuriteDialog({super.key});

  @override
  State<SecuriteDialog> createState() => _SecuriteDialogState();
}

class _SecuriteDialogState extends State<SecuriteDialog> {
  String _currentSubView = 'main'; // 'main', 'password', or 'users'
  
  // Password Form State
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchView(String view) {
    setState(() => _currentSubView = view);
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe mis à jour avec succès'),
            backgroundColor: kPrimaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _switchView('main');
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentSubView) {
      case 'password':
        return _buildPasswordForm();
      case 'users':
        return _buildUserManagement();
      case 'rights':
        return _buildRightsManagement();
      case 'main':
      default:
        return _buildMainList();
    }
  }

  Widget _buildMainList() {
    return SingleChildScrollView(
      key: const ValueKey('main'),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("SÉCURITÉ ET ACCÈS"),
          _buildListItem(
            icon: Icons.lock_reset_rounded,
            title: "Modifier le mot de passe",
            subtitle: "Changez votre mot de passe personnel",
            onTap: () => _switchView('password'),
          ),
          _buildListItem(
            icon: Icons.people_outline_rounded,
            title: "Gestion des collaborateurs",
            subtitle: "Ajouter, modifier ou désactiver des membres",
            onTap: () => _switchView('users'),
          ),
          _buildListItem(
            icon: Icons.admin_panel_settings_outlined,
            title: "Gestion des droits et accès",
            subtitle: "Configurez les permissions par rôle (Admin, Caissier...)",
            onTap: () => _switchView('rights'),
          ),
          _buildListItem(
            icon: Icons.verified_user_outlined,
            title: "Double authentification",
            subtitle: "Sécurité renforcée par email",
            trailing: "Désactivé",
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "Gérez la sécurité de votre compte et les niveaux d'accès de votre équipe pharmaceutique.",
              style: TextStyle(fontSize: 12, color: SettingsTheme.textSecondary, height: 1.5),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return Column(
      key: const ValueKey('users'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _switchView('main'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const Text(
                "Collaborateurs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Expanded(child: UserManagementDialog()),
      ],
    );
  }

  Widget _buildRightsManagement() {
    return Column(
      key: const ValueKey('rights'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _switchView('main'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const Text(
                "Droits et Accès",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Expanded(child: RightsManagementDialog()),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return SingleChildScrollView(
      key: const ValueKey('password'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _switchView('main'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const Text(
                "Changer le mot de passe",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: "Mot de passe actuel",
                  obscure: _obscureCurrent,
                  onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: "Nouveau mot de passe",
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (val) {
                    if (val == null || val.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: "Confirmer le nouveau mot de passe",
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (val) {
                    if (val != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SettingsTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("METTRE À JOUR", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: SettingsTheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SettingsTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: SettingsTheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: SettingsTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: SettingsTheme.primary, fontSize: 13, fontWeight: FontWeight.bold),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: SettingsTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String label, required bool obscure, required VoidCallback onToggle, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ?? (val) => val == null || val.isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: SettingsTheme.textSecondary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
