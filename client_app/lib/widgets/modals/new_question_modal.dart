import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/support_provider.dart';
import '../app_colors.dart';
import '../app_notification.dart';

void showNewQuestionDialog(BuildContext context) {
  final subjectController = TextEditingController();
  final contentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (modalContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nouvelle consultation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(modalContext),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Sujet / Motif de consultation',
                prefixIcon: const Icon(Icons.subject_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Décrivez précisément votre demande',
                prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (subjectController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty) {
                    await context.read<SupportProvider>().createQuestion(
                      subjectController.text.trim(),
                      contentController.text.trim(),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(modalContext);
                    AppScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Votre question a été transmise avec succès.'),
                        backgroundColor: kSuccessGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Envoyer au pharmacien', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
