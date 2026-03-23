import 'package:flutter/material.dart';
import 'settings_theme.dart';

class ProfilDialog extends StatelessWidget {
  const ProfilDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/user_avatar.png'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Jean Dupont',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SettingsTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pharmacien Principal',
            style: TextStyle(fontSize: 16, color: SettingsTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          _buildInfoRow(Icons.email_outlined, 'Email', 'jean.dupont@epharma.com'),
          _buildInfoRow(Icons.phone_outlined, 'Téléphone', '+225 01 02 03 04 05'),
          _buildInfoRow(Icons.business_outlined, 'Société', 'Pharmacie Lafayette'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement Edit Profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SettingsTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Modifier le profil"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SettingsTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: SettingsTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: SettingsTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SettingsTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}


/*_buildTextField(
              controller: _fullNameController,
              label: 'Nom complet',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom complet';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildRoleDropdown(provider),*/
            /*Row(
              children: [
                Expanded(child: _buildPasswordChangeButton()),
                const SizedBox(width: 12),
                Expanded(child: _buildSaveProfileButton(provider)),
              ],
            ),*/