import 'package:flutter/material.dart';

class GestionDonneesDialog extends StatelessWidget {
  const GestionDonneesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestion des données'),
      content: const Text('Options d\'exportation et de sauvegarde des données.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
