import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import '../widgets/app_notification.dart';
import '../widgets/bp_theme.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotIdentifierController = TextEditingController();
  final _resetOtpController = TextEditingController();
  final _resetPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _forgotIdentifierController.dispose();
    _resetOtpController.dispose();
    _resetPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
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
                            const SizedBox(height: 32),
                            _buildDarkField(
                              controller: _identifierController,
                              label: 'Email ou nom d\'utilisateur',
                              hint: 'ex: celeste@bigpharma.bj',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildDarkField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscure: _obscurePassword,
                              onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showPasswordResetSheet,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: BpColors.accent,
                                ),
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            BpButton(
                              label: 'Se connecter',
                              isDark: true,
                              isLoading: isLoading,
                              onPressed: () async {
                                final result = await context
                                    .read<AuthProvider>()
                                    .login(
                                      _identifierController.text.trim(),
                                      _passwordController.text,
                                    );
                                if (!result['success'] && mounted) {
                                  AppScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ??
                                            'Erreur de connexion',
                                      ),
                                      backgroundColor: BpColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Pas encore de compte ?',
                                  style: TextStyle(
                                    color: BpColors.textOnDarkMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: BpColors.accent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BpColors.primary, BpColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: BpColors.primary.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_pharmacy_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'BigPharma',
          style: BpTextStyles.authTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Connectez-vous à votre espace client',
          style: BpTextStyles.authSubtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified_rounded, size: 14, color: BpColors.accent),
              SizedBox(width: 8),
              Text('Accès client', style: BpTextStyles.authBadge),
            ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BpTextStyles.labelOnDark),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: BpInputTheme.dark(
            label: label,
            hint: hint,
            prefixIcon: icon,
            suffixIconWidget: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.55),
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

  void _showPasswordResetSheet() {
    bool requestSent = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: BpColors.surfaceStrong,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(BpSpacing.radiusXl),
              ),
            ),
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              top: 28,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Poignée
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: BpColors.borderStrong,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text(
                  'Réinitialiser le mot de passe',
                  style: BpTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  requestSent
                      ? 'Entrez le code reçu par email et votre nouveau mot de passe.'
                      : 'Entrez votre email pour recevoir un code de vérification.',
                  style: BpTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!requestSent) ...[
                  TextField(
                    controller: _forgotIdentifierController,
                    decoration: BpInputTheme.light(
                      label: 'Email ou nom d\'utilisateur',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BpButton(
                    label: 'Recevoir le code',
                    onPressed: () async {
                      final id = _forgotIdentifierController.text.trim();
                      if (id.isEmpty) return;
                      final result = await context
                          .read<AuthProvider>()
                          .requestPasswordReset(id);
                      if (!mounted) return;
                      if (result['success']) {
                        setModalState(() => requestSent = true);
                        AppScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Code OTP envoyé ! Vérifiez votre email.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        AppScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Erreur'),
                            backgroundColor: BpColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ] else ...[
                  TextField(
                    controller: _resetOtpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: BpInputTheme.light(
                      label: 'Code OTP (6 chiffres)',
                      prefixIcon: Icons.pin_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resetPasswordController,
                    obscureText: true,
                    decoration: BpInputTheme.light(
                      label: 'Nouveau mot de passe',
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BpButton(
                    label: 'Valider le nouveau mot de passe',
                    onPressed: () async {
                      final otp = _resetOtpController.text.trim();
                      final password = _resetPasswordController.text;
                      if (otp.isEmpty || password.isEmpty) return;
                      final result = await context
                          .read<AuthProvider>()
                          .resetPassword(otp, password);
                      if (!mounted) return;
                      if (result['success']) {
                        Navigator.pop(ctx);
                        AppScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mot de passe mis à jour avec succès.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _forgotIdentifierController.clear();
                        _resetOtpController.clear();
                        _resetPasswordController.clear();
                      } else {
                        AppScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Erreur'),
                            backgroundColor: BpColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
