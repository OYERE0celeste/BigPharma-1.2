import 'package:flutter/material.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class ProfileView extends StatefulWidget {
  final bool isInsideDialog;
  const ProfileView({super.key, this.isInsideDialog = false});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Refresh user data from server when opening the profile view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshUser();

      // Safety timeout for loading
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && context.read<AuthProvider>().isLoading) {
          debugPrint('ProfileView: Refresh timeout reached');
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthProvider>().user;

    // Only update controllers if the user is available and we are NOT currently editing
    // This allows the UI to react to background updates (refreshUser)
    if (user != null && !_isEditing) {
      // We check if values are different to avoid cursor jumps
      if (_nameController.text != user.fullName)
        _nameController.text = user.fullName;
      if (_emailController.text != user.email)
        _emailController.text = user.email;
      if (_phoneController.text != user.phone)
        _phoneController.text = user.phone;
      if (_addressController.text != user.address)
        _addressController.text = user.address;
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final result = await auth.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (result['success'] && mounted) {
      setState(() => _isEditing = false);
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final user = context.watch<AuthProvider>().user;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: (user == null && context.watch<AuthProvider>().isLoading)
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Impossible de charger le profil"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AuthProvider>().logout(),
                    child: const Text("Se déconnecter"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(primary, user),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('INFORMATIONS COMPTE'),
                          _buildInfoCard([
                            _buildInfoTile(
                              icon: Icons.person_outline_rounded,
                              label: 'Nom complet',
                              controller: _nameController,
                              isEditing: _isEditing,
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              controller: _emailController,
                              isEditing: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              icon: Icons.phone_outlined,
                              label: 'Téléphone',
                              controller: _phoneController,
                              isEditing: _isEditing,
                              keyboardType: TextInputType.phone,
                              hint: 'Ajouter un numéro',
                            ),
                          ]),

                          const SizedBox(height: 24),
                          _buildSectionTitle('LOCALISATION'),
                          _buildInfoCard([
                            _buildInfoTile(
                              icon: Icons.location_on_outlined,
                              label: 'Adresse',
                              controller: _addressController,
                              isEditing: _isEditing,
                              maxLines: 2,
                              hint: 'Ajouter une adresse',
                            ),
                          ]),

                          const SizedBox(height: 32),
                          _buildActionButtons(primary),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Color primary, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 50, color: primary),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Client',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'En ligne',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 22),
            border: InputBorder.none,
            hintText: hint,
          ),
        ),
      );
    }

    final value = controller.text.isEmpty
        ? (hint ?? 'Non renseigné')
        : controller.text;
    final valueColor = controller.text.isEmpty ? Colors.grey : Colors.black87;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
      subtitle: Text(
        label,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 64, color: Colors.grey[100]);
  }

  Widget _buildActionButtons(Color primary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('MODIFIER LE PROFIL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _isEditing = false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ANNULER'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('ENREGISTRER'),
          ),
        ),
      ],
    );
  }
}
