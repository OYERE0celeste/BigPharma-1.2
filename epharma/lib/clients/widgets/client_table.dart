import 'package:flutter/material.dart';
import '../../widgets/app_colors.dart';
import '../../models/client_model.dart';
import '../../widgets/bp_theme.dart';

class ClientsTable extends StatefulWidget {
  final List<Client> clients;
  final int currentPage;
  final int pageSize;
  final Function(Client) onViewDetails;
  final Function(Client)? onEditClient;
  final Function(Client)? onDeleteClient;
  final Function(List<Client>)? onBulkDelete;
  final Function(int) onPageChanged;

  const ClientsTable({
    required this.clients,
    required this.currentPage,
    required this.pageSize,
    required this.onViewDetails,
    required this.onEditClient,
    required this.onDeleteClient,
    this.onBulkDelete,
    required this.onPageChanged,
    super.key,
  });

  @override
  State<ClientsTable> createState() => _ClientsTableState();
}

class _ClientsTableState extends State<ClientsTable> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.clients.length / widget.pageSize).ceil().clamp(1, 99999);
    // Clamp indices to avoid RangeError when data shrinks or page is out of bounds
    final start = (widget.currentPage * widget.pageSize).clamp(0, widget.clients.length);
    final end = (start + widget.pageSize).clamp(0, widget.clients.length);
    final paginatedClients = widget.clients.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedIds.isNotEmpty && widget.onBulkDelete != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Text(
                  '${_selectedIds.length} client(s) sélectionné(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: BpColors.textPrimary),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    final selectedClients = widget.clients
                         .where((c) => _selectedIds.contains(c.id))
                         .toList();
                    widget.onBulkDelete!(selectedClients);
                    setState(() => _selectedIds.clear());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Supprimer la sélection'),
                ),
              ],
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0,
                    ),
                    child: DataTable(
                      onSelectAll: (isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            _selectedIds.addAll(paginatedClients.map((c) => c.id));
                          } else {
                            _selectedIds.clear();
                          }
                        });
                      },
                      headingRowColor: WidgetStateProperty.all(BpColors.surfaceMuted),
                      columnSpacing: 24,
                      horizontalMargin: 24,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 64,
                      headingRowHeight: 56,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: BpColors.textPrimary,
                      ),
                      columns: const [
                        DataColumn(label: Text('Nom complet')),
                        DataColumn(label: Text('Téléphone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Total Achats')),
                        DataColumn(label: Text('Total Dépensé')),
                        DataColumn(label: Text('Dernière Visite')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Profil Médical')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: paginatedClients.map((client) {
                        final isSelected = _selectedIds.contains(client.id);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedIds.add(client.id);
                              } else {
                                _selectedIds.remove(client.id);
                              }
                            });
                          },
                          cells: [
                            DataCell(Text(client.fullName, style: const TextStyle(color: BpColors.textPrimary, fontWeight: FontWeight.w600))),
                            DataCell(Text(client.phone, style: const TextStyle(color: BpColors.textSecondary))),
                            DataCell(
                              Text(client.email.isNotEmpty ? client.email : '—', style: const TextStyle(color: BpColors.textSecondary)),
                            ),
                            DataCell(Text(client.totalPurchases.toString(), style: const TextStyle(color: BpColors.textSecondary))),
                            DataCell(
                              Text('${client.totalSpent.toStringAsFixed(0)} FCFA', style: const TextStyle(color: BpColors.textPrimary, fontWeight: FontWeight.w600)),
                            ),
                            DataCell(Text(_formatDate(client.lastVisitDate), style: const TextStyle(color: BpColors.textSecondary))),
                            DataCell(Text(client.loyaltyStatus.name.toUpperCase(), style: const TextStyle(color: BpColors.textSecondary))),
                            DataCell(
                              client.hasMedicalHistory
                                  ? const Tooltip(
                                      message: 'Profil médical disponible',
                                      child: Icon(
                                        Icons.check_circle,
                                        color: kPrimaryGreen,
                                        size: 20,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.cancel,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, color: BpColors.textPrimary),
                                    onPressed: () => widget.onViewDetails(client),
                                    tooltip: 'Voir les détails',
                                  ),
                                  if (isSelected) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: BpColors.textPrimary),
                                      onPressed: widget.onEditClient == null
                                          ? null
                                          : () => widget.onEditClient!(client),
                                      tooltip: 'Modifier',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: widget.onDeleteClient == null
                                          ? null
                                          : () => widget.onDeleteClient!(client),
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Affichage de ${start + 1} à $end sur ${widget.clients.length} clients',
              style: const TextStyle(color: BpColors.textSecondary),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: BpColors.textPrimary),
                  onPressed: widget.currentPage > 0
                      ? () => widget.onPageChanged(widget.currentPage - 1)
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => widget.onPageChanged(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.currentPage == index
                            ? kPrimaryGreen
                            : BpColors.surfaceMuted,
                        foregroundColor: BpColors.textPrimary,
                      ),
                      child: Text('${index + 1}'),
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: BpColors.textPrimary),
                  onPressed: widget.currentPage < totalPages - 1
                      ? () => widget.onPageChanged(widget.currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /*Widget _buildLoyaltyBadge(LoyaltyStatus status) {
    late Color color;
    late String label;

    switch (status) {
      case LoyaltyStatus.standard:
        color = Colors.grey;
        label = 'Standard';
        break;
      case LoyaltyStatus.regular:
        color = kAccentBlue;
        label = 'Regular';
        break;
      case LoyaltyStatus.vip:
        color = kPrimaryGreen;
        label = 'VIP';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }*/

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
