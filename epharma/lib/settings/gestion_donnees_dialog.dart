import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'settings_theme.dart';
import '../services/settings_service.dart';
import '../widgets/app_colors.dart';

class GestionDonneesDialog extends StatefulWidget {
  const GestionDonneesDialog({super.key});

  @override
  State<GestionDonneesDialog> createState() => _GestionDonneesDialogState();
}

class _GestionDonneesDialogState extends State<GestionDonneesDialog> {
  final SettingsService _settingsService = SettingsService();
  bool _isBackingUp = false;
  bool _isExporting = false;

  Future<void> _handleBackup() async {
    setState(() => _isBackingUp = true);
    try {
      await _settingsService.backupData();
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sauvegarde effectuée avec succès'),
            backgroundColor: kPrimaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _handleExport(String format) async {
    setState(() => _isExporting = true);
    try {
      await _settingsService.exportData(format);
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportation au format $format démarrée'),
            backgroundColor: kAccentBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          _buildSectionTitle("SAUVEGARDE"),
          _buildInfoCard([
            _buildActionTile(
              icon: Icons.cloud_upload_outlined,
              title: "Créer une sauvegarde",
              subtitle: "Sauvegardez l'état actuel de votre pharmacie",
              trailing: _isBackingUp
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: _isBackingUp ? null : _handleBackup,
            ),
            const Divider(height: 1, indent: 64),
            _buildActionTile(
              icon: Icons.settings_backup_restore_rounded,
              title: "Restaurer les données",
              subtitle: "Importer un fichier de sauvegarde (.json)",
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 32),
          _buildSectionTitle("EXPORTATION DES RAPPORTS"),
          _buildInfoCard([
            _buildActionTile(
              icon: Icons.code_rounded,
              title: "Export JSON",
              subtitle: "Format brut pour développeurs",
              trailing: _isExporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isExporting ? null : () => _handleExport('json'),
            ),
            const Divider(height: 1, indent: 64),
            _buildActionTile(
              icon: Icons.table_chart_outlined,
              title: "Export CSV / Excel",
              subtitle: "Pour vos analyses comptables",
              trailing: _isExporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isExporting ? null : () => _handleExport('csv'),
            ),
            const Divider(height: 1, indent: 64),
            _buildActionTile(
              icon: Icons.picture_as_pdf_outlined,
              title: "Export PDF",
              subtitle: "Rapport d'activité imprimable",
              trailing: _isExporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isExporting ? null : () => _handleExport('pdf'),
            ),
          ]),

          const SizedBox(height: 32),
          _buildSectionTitle("ZONE DE DANGER"),
          _buildInfoCard([
            _buildActionTile(
              icon: Icons.delete_forever_rounded,
              title: "Réinitialiser la pharmacie",
              subtitle: "Efface tous les produits, ventes et clients",
              color: kDangerRed,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SettingsTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storage_rounded,
              color: SettingsTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Gestion des données",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: SettingsTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Exportez vos données de pharmacie ou gérez vos fichiers de sauvegarde.",
            style: TextStyle(
              fontSize: 12,
              color: SettingsTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: SettingsTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SettingsTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    final activeColor = color ?? SettingsTheme.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: activeColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: SettingsTheme.textSecondary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: SettingsTheme.textSecondary,
          ),
    );
  }
}
