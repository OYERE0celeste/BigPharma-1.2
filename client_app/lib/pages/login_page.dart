import 'package:flutter/material.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:provider/provider.dart';
import 'package:client_app/services/auth_provider.dart';
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  size: 40,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bon retour !',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Connectez-vous pour continuer vos achats sur BigPharma',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                labelText: 'Email ou nom d\'utilisateur',
                hintText: 'ex: celeste.karma ou celeste@mail.com',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showPasswordResetSheet,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          final result = await auth.login(
                            _identifierController.text.trim(),
                            _passwordController.text,
                          );
                          if (!result['success']) {
                            if (mounted) {
                              AppScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ?? 'Erreur de connexion',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous n'avez pas de compte ?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Inscrivez-vous'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordResetSheet() {
    bool requestSent = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Réinitialiser le mot de passe',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  requestSent
                      ? 'Entrez le code OTP reçu par email et votre nouveau mot de passe.'
                      : 'Entrez votre email ou nom d\'utilisateur pour recevoir un code OTP.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!requestSent) ...[
                  TextField(
                    controller: _forgotIdentifierController,
                    decoration: InputDecoration(
                      labelText: 'Email ou nom d\'utilisateur',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final identifier = _forgotIdentifierController.text.trim();
                      if (identifier.isEmpty) return;
                      
                      final result = await context.read<AuthProvider>().requestPasswordReset(identifier);
                      
                      if (!mounted) return;
                      
                      if (result['success']) {
                        AppScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code OTP envoyé ! Vérifiez votre email.')),
                        );
                        setModalState(() {
                          requestSent = true;
                        });
                      } else {
                        AppScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Erreur lors de l\'envoi du code'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Recevoir le code', style: TextStyle(fontSize: 16)),
                  ),
                ] else ...[
                  TextField(
                    controller: _resetOtpController,
                    decoration: InputDecoration(
                      labelText: 'Code OTP (6 chiffres)',
                      prefixIcon: const Icon(Icons.pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resetPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final otp = _resetOtpController.text.trim();
                      final password = _resetPasswordController.text;
                      if (otp.isEmpty || password.isEmpty) return;
                      
                      final result = await context.read<AuthProvider>().resetPassword(otp, password);
                      
                      if (!mounted) return;
                      
                      if (result['success']) {
                        Navigator.pop(ctx);
                        AppScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mot de passe mis à jour avec succès.')),
                        );
                        _forgotIdentifierController.clear();
                        _resetOtpController.clear();
                        _resetPasswordController.clear();
                      } else {
                        AppScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Erreur lors de la réinitialisation'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Valider le nouveau mot de passe', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
