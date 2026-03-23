import 'package:flutter/material.dart';
import 'settings_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gestion des Utilisateurs",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SettingsTheme.textPrimary),
                  ),
                  const Text(
                    "Gérez les accès et les rôles de votre équipe",
                    style: TextStyle(color: SettingsTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text("Ajouter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty 
                    ? const Center(child: Text("Aucun utilisateur trouvé"))
                    : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Container(
      decoration: BoxDecoration(
        color: SettingsTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SettingsTheme.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: SettingsTheme.primary.withOpacity(0.1),
              child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: SettingsTheme.primary)),
            ),
            title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("${user.role} • ${user.email}"),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text("Modifier")),
                PopupMenuItem(
                  child: Text(user.isActive ? "Désactiver" : "Réactiver", 
                    style: TextStyle(color: user.isActive ? Colors.red : Colors.green)),
                  onTap: () {
                    // TODO: Implement toggle active
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'pharmacien';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un collaborateur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom complet")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
            DropdownButtonFormField<String>(
              value: role,
              items: ['pharmacien', 'assistant', 'caissier']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => role = val!,
              decoration: const InputDecoration(labelText: "Rôle"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }
}
