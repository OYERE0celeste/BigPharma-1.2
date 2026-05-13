import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epharma/providers/auth_provider.dart';
import 'package:epharma/providers/settings_provider.dart';
import '../widgets/app_colors.dart';

class ProfilDialog extends StatefulWidget {
  const ProfilDialog({super.key});

  @override
  State<ProfilDialog> createState() => _ProfilDialogState();
}

class _ProfilDialogState extends State<ProfilDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Refresh settings data from server when opening the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>().settings;
    final user = context.watch<AuthProvider>().user;

    // Only update controllers if not currently editing
    if (!_isEditing) {
      // Priority: Use authenticated user data first, fallback to settings
      final effectiveFullName = user?.fullName ?? settings.fullName;
      final effectiveEmail = user?.email ?? settings.email;
      final effectivePhone = user?.phone ?? settings.phone;
      final effectiveAddress = user?.address ?? settings.address;

      if (effectiveFullName.isNotEmpty) {
        _nameController.text = effectiveFullName;
        _emailController.text = effectiveEmail;
        _phoneController.text = effectivePhone;
        _addressController.text = effectiveAddress;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final settingsProvider = context.read<SettingsProvider>();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (success) {
      settingsProvider.updateLocalSettings(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        role: settingsProvider.settings.role,
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: kPrimaryGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: kDangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        final user = context.watch<AuthProvider>().user;

        // Priority: Use authenticated user data first, fallback to settings
        // This ensures we always display the connected user's profile, not someone else's
        final effectiveFullName = user?.fullName ?? settings.fullName;
        final effectiveEmail = user?.email ?? settings.email;
        final effectivePhone = user?.phone ?? settings.phone;
        final effectiveAddress = user?.address ?? settings.address;

        final initials = effectiveFullName.trim().isEmpty
            ? '?'
            : effectiveFullName
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .take(2)
                  .map((part) => part[0].toUpperCase())
                  .join();

        return Stack(
          children: [
            Column(
              children: [
                // Header Profile Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryGreen,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: kPrimaryGreen.withOpacity(0.1),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryGreen,
                                ),
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: kPrimaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditing) ...[
                        Text(
                          effectiveFullName.isEmpty
                              ? 'Utilisateur'
                              : effectiveFullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'en ligne',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Info Sections
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F5F7),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('INFORMATIONS PERSONNELLES'),
                            _buildInfoCard([
                              if (_isEditing)
                                _buildEditableRow(
                                  _nameController,
                                  'Nom complet',
                                  Icons.person_outline,
                                )
                              else
                                _buildInfoRow(
                                  'Nom',
                                  effectiveFullName,
                                  Icons.person_outline,
                                ),

                              const Divider(height: 1, indent: 56),

                              if (_isEditing)
                                _buildEditableRow(
                                  _emailController,
                                  'Email',
                                  Icons.email_outlined,
                                )
                              else
                                _buildInfoRow(
                                  'Email',
                                  effectiveEmail,
                                  Icons.email_outlined,
                                ),

                              const Divider(height: 1, indent: 56),

                              if (_isEditing)
                                _buildEditableRow(
                                  _phoneController,
                                  'Numéro de téléphone',
                                  Icons.phone_outlined,
                                )
                              else
                                _buildInfoRow(
                                  'Téléphone',
                                  effectivePhone,
                                  Icons.phone_outlined,
                                ),
                            ]),

                            const SizedBox(height: 24),
                            _buildSectionHeader('LOCALISATION'),
                            _buildInfoCard([
                              if (_isEditing)
                                _buildEditableRow(
                                  _addressController,
                                  'Adresse',
                                  Icons.location_on_outlined,
                                  maxLines: 2,
                                )
                              else
                                _buildInfoRow(
                                  'Adresse',
                                  effectiveAddress,
                                  Icons.location_on_outlined,
                                ),
                            ]),

                            const SizedBox(height: 24),
                            _buildSectionHeader('SÉCURITÉ ET ACCÈS'),
                            _buildInfoCard([
                              _buildInfoRow(
                                'Rôle',
                                (user?.role ?? settings.role).toUpperCase(),
                                Icons.security_outlined,
                              ),
                            ]),

                            const SizedBox(height: 32),
                            _buildActionButtons(provider),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (provider.isLoading)
              Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: kPrimaryGreen),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: kPrimaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600], size: 22),
      title: Text(
        value.isEmpty ? 'Non renseigné' : value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        label,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      dense: true,
    );
  }

  Widget _buildEditableRow(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: kPrimaryGreen),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons(SettingsProvider provider) {
    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('MODIFIER LE PROFIL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() {
              _isEditing = false;
              final settings = provider.settings;
              _nameController.text = settings.fullName;
              _emailController.text = settings.email;
              _phoneController.text = settings.phone;
              _addressController.text = settings.address;
            }),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ANNULER', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ENREGISTRER'),
          ),
        ),
      ],
    );
  }
}
