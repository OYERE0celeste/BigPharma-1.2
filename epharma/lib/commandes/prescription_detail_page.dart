import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/prescription_provider.dart';
import '../services/api_constants.dart';
import '../widgets/bp_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PrescriptionDetailPage extends StatefulWidget {
  final OrderModel order;

  const PrescriptionDetailPage({super.key, required this.order});

  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _validatePrescription() async {
    setState(() => _isProcessing = true);
    
    final authProvider = context.read<AuthProvider>();
    final success = await context.read<PrescriptionProvider>().validatePrescription(
      orderId: widget.order.id,
      token: authProvider.token!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ordonnance validée avec succès')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PrescriptionProvider>().errorMessage ?? 'Erreur lors de la validation')),
      );
    }
  }

  Future<void> _rejectPrescription() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez préciser un motif de refus')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    final authProvider = context.read<AuthProvider>();
    final success = await context.read<PrescriptionProvider>().rejectPrescription(
      orderId: widget.order.id,
      token: authProvider.token!,
      reason: _reasonController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ordonnance refusée')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PrescriptionProvider>().errorMessage ?? 'Erreur lors du refus')),
      );
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser l\'ordonnance'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            labelText: 'Motif du refus',
            hintText: 'Ex: Ordonnance illisible, date expirée...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectPrescription();
            },
            style: ElevatedButton.styleFrom(backgroundColor: BpColors.error, foregroundColor: Colors.white),
            child: const Text('Confirmer le refus'),
          ),
        ],
      ),
    );
  }

  void _showValidateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider l\'ordonnance'),
        content: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes pour le préparateur / client (Optionnel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _validatePrescription();
            },
            style: ElevatedButton.styleFrom(backgroundColor: BpColors.success, foregroundColor: Colors.white),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.prescription?.status ?? 'pending';
    final token = context.read<AuthProvider>().token;
    final imageUrl = '${ApiConstants.baseUrl}/orders/${widget.order.id}/prescription';

    return Scaffold(
      backgroundColor: BpColors.scaffold,
      appBar: AppBar(
        title: Text('Ordonnance - Commande ${widget.order.orderNumber}'),
        backgroundColor: BpColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visualisation de l'ordonnance (Image)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BpColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BpColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  headers: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: BpColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Impossible de charger l\'ordonnance', style: TextStyle(color: BpColors.textSecondary)),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => launchUrl(Uri.parse(imageUrl)),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Ouvrir dans le navigateur'),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Panneau de contrôle
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BpSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Détails du client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildInfoRow('Nom', widget.order.clientName),
                        _buildInfoRow('Date', '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}'),
                        _buildInfoRow('Produits', '${widget.order.items.length} articles'),
                        const Divider(height: 32),
                        const Text('Statut actuel', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildStatusBadge(status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (status == 'pending') ...[
                    BpSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Actions de validation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_isProcessing)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            ElevatedButton.icon(
                              onPressed: _showValidateDialog,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Valider l\'ordonnance'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BpColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _showRejectDialog,
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Refuser'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BpColors.error,
                                side: BorderSide(color: BpColors.error),
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (status == 'rejected') ...[
                    BpSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: BpColors.error),
                              const SizedBox(width: 8),
                              const Text('Motif du refus', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.order.prescription?.rejectionReason ?? 'Non précisé'),
                        ],
                      ),
                    ),
                  ],
                  if (status == 'validated' && widget.order.prescription?.pharmacistNotes != null) ...[
                    BpSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note, color: BpColors.primary),
                              const SizedBox(width: 8),
                              const Text('Notes du pharmacien', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.order.prescription!.pharmacistNotes!),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: BpColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'validated':
        color = BpColors.success;
        text = 'Validée';
        break;
      case 'rejected':
        color = BpColors.error;
        text = 'Refusée';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        text = 'En attente d\'examen';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
