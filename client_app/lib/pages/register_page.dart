import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import '../widgets/app_notification.dart';
import '../widgets/bp_theme.dart';
import 'home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyIdController = TextEditingController(
    text: '69e359c9d74117580fd1e1ce',
  );

  DateTime? _selectedDate;
  String _selectedGender = 'male';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A271F), Color(0xFF133B2E)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    BpColors.accent.withOpacity(0.24),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    BpColors.textPrimary.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: BpColors.cardBg.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: BpColors.borderStrong),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 48,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          BpColors.primary,
                                          BpColors.accent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: BpColors.primary.withOpacity(
                                            0.24,
                                          ),
                                          blurRadius: 22,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Créer un compte',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Rejoignez BigPharma pour une gestion santé fluide et sécurisée.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSectionLabel('Informations personnelles'),
                              const SizedBox(height: 14),
                              _buildFormField(
                                label: 'Nom complet',
                                controller: _fullNameController,
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ce champ est requis'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: 'Email',
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Ce champ est requis';
                                  if (!v.contains('@')) return 'Email invalide';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: 'Téléphone',
                                controller: _phoneController,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ce champ est requis'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: 'Adresse',
                                controller: _addressController,
                                icon: Icons.location_on_outlined,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ce champ est requis'
                                    : null,
                              ),
                              const SizedBox(height: 26),
                              _buildSectionLabel('Sécurité'),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: BpInputTheme.light(
                                  label: 'Mot de passe',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIconWidget: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: BpColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Ce champ est requis';
                                  if (v.length < 6)
                                    return 'Minimum 6 caractères';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26),
                              _buildSectionLabel('Genre'),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: BpColors.cardBg.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(
                                    BpSpacing.radiusLg,
                                  ),
                                  border: Border.all(
                                    color: BpColors.borderStrong,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildGenderOption(
                                        'Homme',
                                        'male',
                                        Icons.male_rounded,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: Colors.white12,
                                    ),
                                    Expanded(
                                      child: _buildGenderOption(
                                        'Femme',
                                        'female',
                                        Icons.female_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26),
                              _buildSectionLabel('Date de naissance'),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().subtract(
                                      const Duration(days: 365 * 20),
                                    ),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: BpColors.primary,
                                        ),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (date != null)
                                    setState(() => _selectedDate = date);
                                },
                                borderRadius: BorderRadius.circular(
                                  BpSpacing.radiusMd,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BpColors.cardBg.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(
                                      BpSpacing.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: _selectedDate != null
                                          ? BpColors.accent
                                          : BpColors.borderStrong,
                                      width: _selectedDate != null ? 2 : 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: _selectedDate != null
                                            ? BpColors.accent
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null
                                              ? 'Sélectionner votre date de naissance'
                                              : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _selectedDate == null
                                                ? Colors.white60
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => BpButton(
                                  label: 'Créer mon compte',
                                  isLoading: auth.isLoading,
                                  onPressed: _handleRegister,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: const Text(
                                    'Vous avez déjà un compte ? Se connecter',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: BpColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: BpColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: BpInputTheme.light(label: label, prefixIcon: icon),
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BpColors.primary.withOpacity(0.06) : null,
          borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? BpColors.primary : BpColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? BpColors.primary : BpColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final result = await auth.registerClient(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      dateOfBirth: _selectedDate!.toIso8601String(),
      gender: _selectedGender,
      address: _addressController.text,
      companyId: _companyIdController.text,
    );

    if (!mounted) return;
    if (result['success']) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Bienvenue sur BigPharma.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de l\'inscription'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
