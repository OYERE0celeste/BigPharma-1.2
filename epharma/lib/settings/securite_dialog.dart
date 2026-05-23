import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
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
  String _currentSubView = 'main';
  String _auditSearchQuery = '';
  String _selectedAuditType = 'Tous'; // 'main', 'password', or 'users'
  final List<String> _subViewHistory = ['main'];
  bool _isGoingBack = false;

  void _switchView(String view) {
    setState(() {
      _subViewHistory.add(view);
      _currentSubView = view;
      _isGoingBack = false;
    });
  }

  void _navigateBack() {
    if (_subViewHistory.length > 1) {
      setState(() {
        _subViewHistory.removeLast();
        _currentSubView = _subViewHistory.last;
        _isGoingBack = true;
      });
    }
  }

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
        AppScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe mis à jour avec succès'),
            backgroundColor: kPrimaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _subViewHistory.clear();
          _subViewHistory.add('main');
          _currentSubView = 'main';
          _isGoingBack = true;
        });
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isEntering = child.key == ValueKey(_currentSubView);
        Offset beginOffset;
        if (_isGoingBack) {
          beginOffset = isEntering ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
        } else {
          beginOffset = isEntering ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
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
        key: ValueKey(_currentSubView),
        child: _buildCurrentView(),
      ),
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
      case 'audit_logs':
        return _buildAuditLogs();
      case 'main':
      default:
        return _buildMainList();
    }
  }  Widget _buildMainList() {
    return SingleChildScrollView(
      key: const ValueKey('main'),
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
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: SettingsTheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sécurité de la pharmacie",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: SettingsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Gérez la sécurité de votre compte et les droits d'accès de l'équipe.",
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SettingsTheme.divider),
            ),
            child: Column(
              children: [
                _buildListItemInCard(
                  icon: Icons.lock_reset_rounded,
                  title: "Modifier le mot de passe",
                  subtitle: "Changez votre mot de passe personnel",
                  onTap: () => _switchView('password'),
                ),
                const Divider(height: 1, color: SettingsTheme.divider, indent: 64),
                _buildListItemInCard(
                  icon: Icons.people_outline_rounded,
                  title: "Gestion des collaborateurs",
                  subtitle: "Ajouter, modifier ou désactiver des membres",
                  onTap: () => _switchView('users'),
                ),
                const Divider(height: 1, color: SettingsTheme.divider, indent: 64),
                _buildListItemInCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: "Gestion des droits et accès",
                  subtitle: "Configurez les permissions par rôle (Admin, Caissier...)",
                  onTap: () => _switchView('rights'),
                ),
                const Divider(height: 1, color: SettingsTheme.divider, indent: 64),
                _buildListItemInCard(
                  icon: Icons.security_rounded,
                  title: "Journal d'audit de sécurité",
                  subtitle: "Consultez l'historique complet des actions système",
                  onTap: () {
                    // Pre-load activities
                    Provider.of<ActivityProvider>(context, listen: false).loadActivities();
                    _switchView('audit_logs');
                  },
                ),
                const Divider(height: 1, color: SettingsTheme.divider, indent: 64),
                _buildListItemInCard(
                  icon: Icons.verified_user_outlined,
                  title: "Double authentification",
                  subtitle: "Sécurité renforcée par email",
                  trailing: "Désactivé",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                onPressed: _navigateBack,
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
                onPressed: _navigateBack,
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
                onPressed: _navigateBack,
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
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: "Nouveau mot de passe",
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Minimum 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: "Confirmer le nouveau mot de passe",
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (val) {
                    if (val != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "METTRE À JOUR",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
              if (trailing != null)
                Text(
                  trailing,
                  style: const TextStyle(
                    color: SettingsTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          validator ??
          (val) => val == null || val.isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: SettingsTheme.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildListItemInCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SettingsTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: SettingsTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SettingsTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SettingsTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  color: SettingsTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: SettingsTheme.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogs() {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final activities = activityProvider.activities;
    
    // Filtering logic
    final filteredActivities = activities.where((activity) {
      // 1. Search Query filter
      final query = _auditSearchQuery.toLowerCase();
      final matchesQuery = activity.employeeName.toLowerCase().contains(query) ||
          activity.notes.toLowerCase().contains(query) ||
          activity.reference.toLowerCase().contains(query);
          
      // 2. Type filter
      if (_selectedAuditType == 'Tous') return matchesQuery;
      
      String targetTypeStr = '';
      switch (_selectedAuditType) {
        case 'Ventes':
          targetTypeStr = 'sale';
          break;
        case 'Commandes':
          targetTypeStr = 'order';
          break;
        case 'Stock':
          targetTypeStr = 'restocking';
          break;
        case 'Collaborateurs':
          targetTypeStr = 'userAction';
          break;
        case 'Finance':
          targetTypeStr = 'financeAction';
          break;
      }
      
      final matchesType = activity.type.name == targetTypeStr || 
          (_selectedAuditType == 'Stock' && activity.type.name == 'stockAdjustment');
          
      return matchesQuery && matchesType;
    }).toList();

    return Column(
      key: const ValueKey('audit_logs'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: _navigateBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const Text(
                "Journal d'audit de sécurité",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SettingsTheme.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: kPrimaryGreen),
                onPressed: () => activityProvider.loadActivities(),
                tooltip: 'Actualiser',
              ),
            ],
          ),
        ),

        // Search Bar & Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Search input
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur, une action, une réf...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _auditSearchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 12),
              
              // Filter chips scrollable Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tous', 'Ventes', 'Commandes', 'Stock', 'Collaborateurs', 'Finance'].map((type) {
                    final isSelected = _selectedAuditType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: kPrimaryGreen.withOpacity(0.12),
                        checkmarkColor: kPrimaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? kPrimaryGreen : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? kPrimaryGreen.withOpacity(0.3) : Colors.transparent,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedAuditType = type;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Logs List
        Expanded(
          child: activityProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                  ),
                )
              : filteredActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aucun log d'activité trouvé",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final log = filteredActivities[index];
                        final timeStr = "${log.dateTime.hour.toString().padLeft(2, '0')}:${log.dateTime.minute.toString().padLeft(2, '0')}";
                        final dateStr = "${log.dateTime.day}/${log.dateTime.month}/${log.dateTime.year}";
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SettingsTheme.divider),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: log.typeColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                log.typeIcon,
                                color: log.typeColor,
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    log.employeeName.isNotEmpty ? log.employeeName : "Système",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: SettingsTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    log.typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: log.typeColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  log.notes,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$dateStr à $timeStr",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    if (log.reference.isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      Icon(Icons.tag_rounded, size: 12, color: Colors.grey[400]),
                                      const SizedBox(width: 2),
                                      Text(
                                        log.reference,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              _showLogDetailsSheet(context, log);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showLogDetailsSheet(BuildContext context, ActivityModel log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final dateStr = "${log.dateTime.day}/${log.dateTime.month}/${log.dateTime.year} ${log.dateTime.hour.toString().padLeft(2, '0')}:${log.dateTime.minute.toString().padLeft(2, '0')}";
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: log.typeColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(log.typeIcon, color: log.typeColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Détail du log de sécurité",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: SettingsTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: log.typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow("Opérateur", log.employeeName.isNotEmpty ? log.employeeName : "Système"),
              const SizedBox(height: 12),
              _buildDetailRow("Horodatage", dateStr),
              if (log.reference.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow("ID Référence / Réf", log.reference),
              ],
              const SizedBox(height: 12),
              _buildDetailRow("Action", log.notes),
              if (log.totalAmount > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Montant associé", "${log.totalAmount.toStringAsFixed(2)} FCFA"),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[800],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: SettingsTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

}