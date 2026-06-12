import 'package:flutter/material.dart';
import 'package:epharma/widgets/app_notification.dart';
import 'settings_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/app_colors.dart';
import '../widgets/bp_theme.dart';

class UserManagementDialog extends StatefulWidget {
  const UserManagementDialog({super.key});

  @override
  State<UserManagementDialog> createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends State<UserManagementDialog> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() => _isLoading = true);
      final users = await _authService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      final newStatus = !user.isActive;
      await _authService.updateUser(user.id, {'isActive': newStatus});

      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur ${newStatus ? 'réactivé' : 'désactivé'} avec succès',
            ),
            backgroundColor: newStatus ? kPrimaryGreen : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        AppScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual People Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SettingsTheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    color: SettingsTheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Gestion des collaborateurs",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: SettingsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gérez votre équipe pharmaceutique et configurez leurs accès.",
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

          // Actions Row (List Count and ADD button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_users.length} collaborateur(s)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: SettingsTheme.textSecondary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text(
                  "AJOUTER",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primary,
                  foregroundColor: BpColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: SettingsTheme.primary,
                    ),
                  )
                : _users.isEmpty
                ? _buildEmptyState()
                : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucun collaborateur",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text("Commencez par ajouter votre premier employé"),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _users[index];
        return Container(
          decoration: BoxDecoration(
            color: SettingsTheme.background,
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: SettingsTheme.primary.withOpacity(0.1),
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: SettingsTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: user.isActive ? kPrimaryGreen : kDangerRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: SettingsTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: _buildPopupMenu(user),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color = SettingsTheme.primary;
    if (role == 'administrateur') color = Colors.purple;
    if (role == 'assistante de gestion') color = Colors.orange;
    if (role == 'caissier') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(UserModel user) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (val) {
        if (val == 'status') {
          _toggleUserStatus(user);
        } else if (val == 'delete') {
          _showDeleteConfirm(user);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(
                user.isActive
                    ? Icons.block_flipped
                    : Icons.check_circle_outline,
                size: 18,
                color: user.isActive ? kDangerRed : kPrimaryGreen,
              ),
              const SizedBox(width: 12),
              Text(
                user.isActive ? "Désactiver" : "Réactiver",
                style: TextStyle(
                  color: user.isActive ? kDangerRed : kPrimaryGreen,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: kDangerRed),
              SizedBox(width: 12),
              Text("Supprimer", style: TextStyle(color: kDangerRed)),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'pharmacien';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isAssistant = role == 'assistante de gestion';
          final hasAssistant = _users.any(
            (u) => u.role == 'assistante de gestion' && u.isActive,
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Nouveau collaborateur"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(nameCtrl, "Nom complet", Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildField(emailCtrl, "Email", Icons.email_outlined),
                  const SizedBox(height: 12),
                  _buildField(
                    passCtrl,
                    "Mot de passe",
                    Icons.lock_outline,
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: _inputDecoration("Rôle", Icons.badge_outlined),
                    items:
                        [
                              'pharmacien',
                              'caissier',
                              'gestionnaire de stock',
                              'assistante de gestion',
                            ]
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                    onChanged: (val) => setDialogState(() => role = val!),
                  ),
                  if (isAssistant && hasAssistant)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Une assistante de gestion est déjà active.",
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "ANNULER",
                  style: TextStyle(color: SettingsTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: (isAssistant && hasAssistant)
                    ? null
                    : () async {
                        try {
                          await _authService.createUser({
                            'fullName': nameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'password': passCtrl.text,
                            'role': role,
                          });
                          if (mounted) {
                            Navigator.pop(context);
                            _fetchUsers();
                          }
                        } catch (e) {
                          AppScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                              backgroundColor: kDangerRed,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("AJOUTER"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirm(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'utilisateur ?"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer ${user.fullName} ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _authService.deleteUser(user.id);
                if (mounted) {
                  Navigator.pop(context);
                  _fetchUsers();
                }
              } catch (e) {
                AppScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: kDangerRed,
                  ),
                );
              }
            },
            child: const Text("SUPPRIMER", style: TextStyle(color: kDangerRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: SettingsTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
