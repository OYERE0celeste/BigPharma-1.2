import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'settings_theme.dart';

class ProfilDialog extends StatelessWidget {
  const ProfilDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        final initials = settings.fullName.trim().isEmpty
            ? '?'
            : settings.fullName
                .trim()
                .split(RegExp(r'\s+'))
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part[0].toUpperCase())
                .join();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: SettingsTheme.primary.withOpacity(0.12),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: SettingsTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                settings.fullName.isEmpty ? 'Utilisateur' : settings.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: SettingsTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                settings.role.isEmpty ? 'Profil' : settings.role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: SettingsTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                settings.email.isEmpty ? 'Non renseigné' : settings.email,
              ),
              _buildInfoRow(Icons.phone_outlined, 'Téléphone', 'À renseigner'),
              _buildInfoRow(
                Icons.verified_user_outlined,
                'Rôle',
                settings.role.isEmpty ? 'Non renseigné' : settings.role,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: SettingsTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SettingsTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
