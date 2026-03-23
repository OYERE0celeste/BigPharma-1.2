import 'package:flutter/material.dart';

class SecuriteDialog extends StatelessWidget {
  const SecuriteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sécurité'),
      content: const Text('Options de sécurité et modification du mot de passe.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
