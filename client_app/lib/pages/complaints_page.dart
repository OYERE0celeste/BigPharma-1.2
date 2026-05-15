import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../services/complaint_provider.dart';
import '../services/order_provider.dart';

class ComplaintsPage extends StatefulWidget {
  final String? initialOrderId;

  const ComplaintsPage({super.key, this.initialOrderId});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ComplaintProvider>().loadComplaints();
      if (context.read<OrderProvider>().orders.isEmpty) {
        await context.read<OrderProvider>().loadMyOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes réclamations'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateComplaintSheet,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateComplaintSheet,
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Nouvelle'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ComplaintProvider>().loadComplaints(
          status: _selectedStatus,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filtrer par statut',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tous les statuts'),
                ),
                DropdownMenuItem(
                  value: 'en_attente',
                  child: Text('En attente'),
                ),
                DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                DropdownMenuItem(value: 'resolue', child: Text('Résolue')),
                DropdownMenuItem(value: 'rejetee', child: Text('Rejetée')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<ComplaintProvider>().loadComplaints(status: value);
              },
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.complaints.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.complaints.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(
                  child: Text('Aucune réclamation enregistrée pour le moment.'),
                ),
              )
            else
              ...provider.complaints.map(_buildComplaintCard),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    Color color;
    switch (complaint.status) {
      case 'resolue':
        color = Colors.green;
        break;
      case 'rejetee':
        color = Colors.red;
        break;
      case 'en_cours':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.complaintNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    complaint.statusLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.subject,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              complaint.categoryLabel,
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (complaint.orderNumber.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Commande: ${complaint.orderNumber}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              formatter.format(complaint.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (complaint.resolutionNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(complaint.resolutionNote),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateComplaintSheet() async {
    final provider = context.read<ComplaintProvider>();
    final orderProvider = context.read<OrderProvider>();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    var category = 'mauvaise_commande';
    String? selectedOrderId = widget.initialOrderId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouvelle réclamation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Commande concernée',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Sujet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Décrivez le problème',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            await provider.createComplaint(
                              category: category,
                              subject: subjectController.text.trim(),
                              description: descriptionController.text.trim(),
                              orderId: selectedOrderId,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Réclamation envoyée avec succès.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text('Envoyer la réclamation'),
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
}
