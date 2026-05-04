import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  final _fullNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _companyEmailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _fullNameController.dispose();
    _adminEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleRegister();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .register(
          companyName: _nameController.text.trim(),
          companyEmail: _companyEmailController.text.trim(),
          companyPhone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          country: _countryController.text.trim(),
          fullName: _fullNameController.text.trim(),
          adminEmail: _adminEmailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      final error = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "Échec de l'inscription")),
      );
    }
  }

  String? _validateRequired(
    String? value,
    String fieldName, {
    int minLength = 1,
  }) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName est requis";
    }
    if (minLength > 1 && value.trim().length < minLength) {
      return "$fieldName doit contenir au moins $minLength caractères";
    }
    return null;
  }

  String? _validateEmail(String? value, String fieldName) {
    final required = _validateRequired(value, fieldName);
    if (required != null) return required;

    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return "$fieldName est invalide";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final required = _validateRequired(value, "Téléphone", minLength: 8);
    if (required != null) return required;

    final trimmed = value!.trim();
    if (!RegExp(r'^[0-9]{8,}$').hasMatch(trimmed)) {
      return "Téléphone invalide, au moins 8 chiffres";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final required = _validateRequired(value, "Mot de passe", minLength: 8);
    if (required != null) return required;
    if (value!.length < 8) {
      return "Le mot de passe doit contenir au moins 8 caractères";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildStepIndicator(),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 400,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildCompanyStep(),
                                _buildAdminStep(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFooter(isLoading),
                        ],
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
      children: [
        const Icon(
          Icons.add_business_rounded,
          size: 48,
          color: Color(0xFF6366F1),
        ),
        const SizedBox(height: 12),
        const Text(
          "Inscription Pharmacie",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _currentStep == 0
              ? "Étape 1: Ma Pharmacie"
              : "Étape 2: Administrateur",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        const SizedBox(width: 12),
        Container(width: 40, height: 2, color: Colors.white10),
        const SizedBox(width: 12),
        _buildDot(1),
      ],
    );
  }

  Widget _buildDot(int index) {
    final active = _currentStep >= index;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : Colors.white10,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? const Color(0xFF6366F1) : Colors.white30,
        ),
      ),
    );
  }

  Widget _buildCompanyStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: "Nom de la Pharmacie",
          hint: "Pharmacie du Centre",
          icon: Icons.business,
          validator: (value) =>
              _validateRequired(value, "Nom de la Pharmacie", minLength: 2),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _companyEmailController,
          label: "Email Professionnel",
          hint: "contact@pharmacie.com",
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => _validateEmail(value, "Email Professionnel"),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: "Téléphone",
          hint: "0123456789",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: "Adresse Complète",
          hint: "123 Rue de la Santé",
          icon: Icons.location_on_outlined,
          validator: (value) =>
              _validateRequired(value, "Adresse Complète", minLength: 3),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _countryController,
          label: "Pays",
          hint: "Gabon",
          icon: Icons.flag_outlined,
          validator: (value) => _validateRequired(value, "Pays", minLength: 2),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cityController,
          label: "Ville",
          hint: "Libreville",
          icon: Icons.location_city_outlined,
          validator: (value) => _validateRequired(value, "Ville", minLength: 2),
        ),
      ],
    );
  }

  Widget _buildAdminStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: "Nom complet de l'Admin",
          hint: "Jean Dupont",
          icon: Icons.person_outline,
          validator: (value) =>
              _validateRequired(value, "Nom complet de l'Admin", minLength: 2),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _adminEmailController,
          label: "Email de connexion",
          hint: "admin@pharmacie.com",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => _validateEmail(value, "Email de connexion"),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: "Mot de passe",
          hint: "••••••••",
          icon: Icons.lock_outline,
          isPassword: true,
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        const Text(
          "Ce compte sera l'administrateur principal de votre espace pharmacie.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: isLoading ? null : _previousStep,
          child: Text(
            _currentStep == 0 ? "Annuler" : "Retour",
            style: const TextStyle(color: Colors.white60),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(_currentStep == 0 ? "Suivant" : "S'inscrire"),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
      ],
    );
  }
}
