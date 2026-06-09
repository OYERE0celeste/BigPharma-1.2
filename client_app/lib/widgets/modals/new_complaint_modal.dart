import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/complaint_provider.dart';
import '../../services/order_provider.dart';
import '../../models/order.dart';
import '../app_colors.dart';
import '../app_notification.dart';

Future<void> showCreateComplaintSheet(BuildContext context, {String? initialOrderId}) async {
  final provider = context.read<ComplaintProvider>();
  final orderProvider = context.read<OrderProvider>();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  var category = 'mauvaise_commande';
  String? selectedOrderId = initialOrderId;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nouvelle réclamation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Catégorie de réclamation',
                      prefixIcon: const Icon(Icons.category_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'produit_endommage',
                        child: Text('Produit endommagé'),
                      ),
                      DropdownMenuItem(
                        value: 'mauvaise_commande',
                        child: Text('Mauvaise commande'),
                      ),
                      DropdownMenuItem(
                        value: 'retard_livraison',
                        child: Text('Retard de livraison'),
                      ),
                      DropdownMenuItem(
                        value: 'produit_manquant',
                        child: Text('Produit manquant'),
                      ),
                      DropdownMenuItem(
                        value: 'erreur_facture',
                        child: Text('Erreur facture'),
                      ),
                      DropdownMenuItem(
                        value: 'probleme_utilisation',
                        child: Text('Problème d’utilisation'),
                      ),
                      DropdownMenuItem(value: 'autre', child: Text('Autre')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => category = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: selectedOrderId,
                    decoration: InputDecoration(
                      labelText: 'Commande concernée',
                      prefixIcon: const Icon(Icons.receipt_long_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Aucune commande spécifique'),
                      ),
                      ...orderProvider.orders.map(
                        (Order order) => DropdownMenuItem<String?>(
                          value: order.id,
                          child: Text(order.orderNumber),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedOrderId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Sujet succinct',
                      prefixIcon: const Icon(Icons.subject_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Décrivez en détail le problème rencontré',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (subjectController.text.trim().isEmpty ||
                            descriptionController.text.trim().isEmpty) {
                          return;
                        }
                        try {
                          await provider.createComplaint(
                            category: category,
                            subject: subjectController.text.trim(),
                            description: descriptionController.text.trim(),
                            orderId: selectedOrderId,
                          );
                          if (!modalContext.mounted) return;
                          Navigator.pop(modalContext);
                          AppScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Réclamation envoyée avec succès.'),
                              backgroundColor: kSuccessGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!modalContext.mounted) return;
                          AppScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: kErrorRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Envoyer la réclamation', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
