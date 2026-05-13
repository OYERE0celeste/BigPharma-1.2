import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../security/rbac.dart';
import '../services/auth_service.dart';
import '../widgets/app_colors.dart';
import 'settings_theme.dart';

class RightsManagementDialog extends StatefulWidget {
  const RightsManagementDialog({super.key});

  @override
  State<RightsManagementDialog> createState() => _RightsManagementDialogState();
}

class _RightsManagementDialogState extends State<RightsManagementDialog> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  int? _expandedIndex;
  final Map<String, Map<String, bool>> _pendingPermissions = {};

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
        _pendingPermissions.clear();
        for (final user in users) {
          _pendingPermissions[user.id] =
              normalizePermissions(user.role, Map<String, bool>.from(user.permissions));
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: kDangerRed,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePermissions(UserModel user) async {
    try {
      final perms = _pendingPermissions[user.id];
      await _authService.updateUser(user.id, {'permissions': perms});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions mises a jour avec succes'),
            backgroundColor: kPrimaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roles & Permissions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SettingsTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Controle central des acces, de la navigation et des actions par role.',
            style: TextStyle(
              color: SettingsTheme.textSecondary.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: SettingsTheme.primary),
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
          Icon(Icons.lock_person_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun utilisateur a configurer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final isExpanded = _expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? SettingsTheme.primary : SettingsTheme.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: SettingsTheme.primary.withOpacity(0.1),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: SettingsTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: _buildRoleBadge(user.role),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? SettingsTheme.primary : Colors.grey,
                ),
              ),
              if (isExpanded) _buildPermissionEditor(user),
            ],
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionEditor(UserModel user) {
    final userPerms = _pendingPermissions[user.id] ?? {};
    final locked = kSystemLocked[user.role] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...kPermissionCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(
                    category.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: SettingsTheme.textSecondary.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: category.value.map((permission) {
                    final isLocked = locked.contains(permission);
                    final isEnabled = userPerms[permission] ?? false;

                    return SizedBox(
                      width: 270,
                      child: _buildPermissionToggle(
                        label: kPermissionLabels[permission] ?? permission,
                        value: isEnabled,
                        isLocked: isLocked,
                        onChanged: (value) {
                          setState(() {
                            userPerms[permission] = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _pendingPermissions[user.id] =
                        Map<String, bool>.from(kRoleDefaults[user.role] ?? permissionMap(const []));
                  });
                },
                child: const Text('Reinitialiser'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _updatePermissions(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle({
    required String label,
    required bool value,
    required bool isLocked,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLocked ? Colors.grey[200]! : SettingsTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isLocked ? Colors.grey : SettingsTheme.textPrimary,
                fontWeight: isLocked ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey)
          else
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: SettingsTheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}
