import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/complaint_provider.dart';
import '../../widgets/app_colors.dart';

class ComplaintsTab extends StatefulWidget {
  final String? initialStatus;
  final Function(String?) onStatusChanged;

  const ComplaintsTab({
    super.key,
    this.initialStatus,
    required this.onStatusChanged,
  });

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  String? _selectedComplaintStatus;

  @override
  void initState() {
    super.initState();
    _selectedComplaintStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.complaints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DropdownButtonFormField<String?>(
                value: _selectedComplaintStatus,
                decoration: InputDecoration(
                  labelText: 'Filtrer par statut',
                  prefixIcon: const Icon(Icons.filter_list_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  setState(() => _selectedComplaintStatus = value);
                  widget.onStatusChanged(value);
                },
              ),
            ),
            Expanded(
              child: provider.complaints.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.report_problem_outlined, size: 64, color: Colors.red[300]),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Aucune réclamation',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vous n’avez aucune réclamation enregistrée pour le moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: provider.complaints.length,
                      itemBuilder: (context, index) {
                        return _buildComplaintCard(provider.complaints[index]);
                      },
                    ),
            ),
          ],
        );
      },
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
        color = kAccentBlue;
        break;
      default:
        color = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
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
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildStatusChip(complaint.statusLabel, color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                complaint.subject,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                complaint.categoryLabel,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              if (complaint.orderNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Commande: ${complaint.orderNumber}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(complaint.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              if (complaint.resolutionNote.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Note de résolution',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complaint.resolutionNote,
                        style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
