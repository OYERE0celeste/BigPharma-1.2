import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/bp_theme.dart';
import '../../widgets/brand_title.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;

  // Step 1 controllers (Pharmacy Info)
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Bénin');

  // Step 2 controllers (Admin Info)
  final _fullNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _fullNameController.dispose();
    _adminEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate Step 1 fields
    if (_companyNameController.text.trim().isEmpty ||
        _companyEmailController.text.trim().isEmpty ||
        _companyPhoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs de la pharmacie'),
          backgroundColor: BpColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Email validation
    final emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailExp.hasMatch(_companyEmailController.text.trim())) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un email de pharmacie valide'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _handleRegister() async {
    // Validate Step 2 fields
    if (_fullNameController.text.trim().isEmpty ||
        _adminEmailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez remplir tous les champs de l\'administrateur',
          ),
          backgroundColor: BpColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailExp.hasMatch(_adminEmailController.text.trim())) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un email d\'administrateur valide'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await context.read<AuthProvider>().register(
      companyName: _companyNameController.text.trim(),
      companyEmail: _companyEmailController.text.trim(),
      companyPhone: _companyPhoneController.text.trim(),
      address: _addressController.text.trim(),
      fullName: _fullNameController.text.trim(),
      adminEmail: _adminEmailController.text.trim(),
      password: _passwordController.text,
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
    );

    if (success && mounted) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compte créé avec succès ! Bienvenue.'),
          backgroundColor: BpColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = context.read<AuthProvider>().errorMessage;
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Échec de l\'inscription'),
          backgroundColor: BpColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isLightTheme = BpColors.scaffold.computeLuminance() > 0.5;
    final cardColor = isLightTheme
        ? BpColors.surfaceStrong.withOpacity(0.96)
        : BpColors.cardBg.withOpacity(0.12);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [BpColors.authBg1, BpColors.authBg2, BpColors.authBg3],
              ),
            ),
          ),
          Positioned(
            top: -140,
            right: -100,
            child: _buildBlob(390, BpColors.primary.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildBlob(320, BpColors.accent.withOpacity(0.10)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: BpColors.borderStrong,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 34,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            _buildStepIndicator(),
                            const SizedBox(height: 24),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _currentStep == 0
                                  ? _buildPharmacyForm()
                                  : _buildAdminForm(),
                            ),
                            const SizedBox(height: 28),
                            _buildActionButtons(isLoading),
                            const SizedBox(height: 24),
                            _buildFooter(),
                          ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BrandTitle(style: BpTextStyles.authTitle),
        const SizedBox(height: 6),
        Text(
          'Créer un compte partenaire',
          style: BpTextStyles.authSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape 1: Pharmacie',
                style: TextStyle(
                  color: _currentStep == 0
                      ? BpColors.accent
                      : BpColors.textOnDarkMuted,
                  fontWeight: _currentStep == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep >= 0
                      ? BpColors.accent
                      : BpColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape 2: Administrateur',
                style: TextStyle(
                  color: _currentStep == 1
                      ? BpColors.accent
                      : BpColors.textOnDarkMuted,
                  fontWeight: _currentStep == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep >= 1
                      ? BpColors.accent
                      : BpColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyForm() {
    return Column(
      key: const ValueKey('pharmacy_form'),
      children: [
        _buildDarkField(
          controller: _companyNameController,
          label: 'Nom de la Pharmacie',
          hint: 'ex: Pharmacie du Centre',
          icon: Icons.local_pharmacy_outlined,
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _companyEmailController,
          label: 'Email Professionnel de la Pharmacie',
          hint: 'ex: contact@pharmacie.bj',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _companyPhoneController,
          label: 'Numéro de Téléphone',
          hint: 'ex: +229 90000000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _addressController,
          label: 'Adresse Physique',
          hint: 'ex: Carré 120, Avenue de la Paix',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDarkField(
                controller: _cityController,
                label: 'Ville',
                hint: 'ex: Cotonou',
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDarkField(
                controller: _countryController,
                label: 'Pays',
                hint: 'ex: Bénin',
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Column(
      key: const ValueKey('admin_form'),
      children: [
        _buildDarkField(
          controller: _fullNameController,
          label: 'Nom Complet de l\'Administrateur',
          hint: 'ex: Jean Dupont',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _adminEmailController,
          label: 'Email de Connexion Administrateur',
          hint: 'ex: admin@pharmacie.bj',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 16),
        _buildDarkField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          hint: '••••••••',
          icon: Icons.lock_clock_outlined,
          isPassword: true,
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    if (_currentStep == 0) {
      return BpButton(label: 'Continuer', isDark: true, onPressed: _nextStep);
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : _previousStep,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: BpColors.borderStrong),
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
              ),
            ),
            child: Text(
              'Retour',
              style: TextStyle(
                color: BpColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BpButton(
            label: 'S\'inscrire',
            isDark: true,
            isLoading: isLoading,
            onPressed: _handleRegister,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ?',
          style: TextStyle(color: BpColors.textOnDarkMuted, fontSize: 13),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: BpColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Se connecter',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BpTextStyles.labelOnDark),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: BpColors.textPrimary, fontSize: 14),
          decoration: BpInputTheme.dark(
            label: label,
            hint: hint,
            prefixIcon: icon,
            showLabel: false,
            suffixIconWidget: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: BpColors.textPrimary.withOpacity(0.55),
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
