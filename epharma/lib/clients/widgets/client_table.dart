import 'package:flutter/material.dart';
import '../../widgets/app_colors.dart';
import '../../models/client_model.dart';

class ClientsTable extends StatelessWidget {
  final List<Client> clients;
  final int currentPage;
  final int pageSize;
  final Function(Client) onViewDetails;
  final Function(Client) onEditClient;
  final Function(Client) onDeleteClient;
  final Function(int) onPageChanged;

  const ClientsTable({
    required this.clients,
    required this.currentPage,
    required this.pageSize,
    required this.onViewDetails,
    required this.onEditClient,
    required this.onDeleteClient,
    required this.onPageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (clients.length / pageSize).ceil();
    final start = currentPage * pageSize;
    final end = start + pageSize;
    final paginatedClients = clients.sublist(
      start,
      end > clients.length ? clients.length : end,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Téléphone')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Total Purchases')),
              DataColumn(label: Text('Total Spent')),
              DataColumn(label: Text('Dernière Visite')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Profil Médical')),
              DataColumn(label: Text('Actions')),
            ],
            rows: paginatedClients.map((client) {
              return DataRow(
                onSelectChanged: (_) => onViewDetails(client),
                cells: [
                  DataCell(Text(client.fullName)),
                  DataCell(Text(client.phone)),
                  DataCell(Text(client.email.isNotEmpty ? client.email : '—')),
                  DataCell(Text(client.totalPurchases.toString())),
                  DataCell(Text('€${client.totalSpent.toStringAsFixed(2)}')),
                  DataCell(Text(_formatDate(client.lastVisitDate))),
                  DataCell(Text(client.loyaltyStatus.name.toUpperCase())),
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
                          icon: const Icon(Icons.visibility_outlined),
                          onPressed: () => onViewDetails(client),
                          tooltip: 'Voir les détails',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => onEditClient(client),
                          tooltip: 'Modifier',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDeleteClient(client),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${start + 1} to ${end > clients.length ? clients.length : end} of ${clients.length} clients',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 0
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => onPageChanged(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage == index
                            ? kPrimaryGreen
                            : Colors.grey[300],
                        foregroundColor: currentPage == index
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: Text('${index + 1}'),
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages - 1
                      ? () => onPageChanged(currentPage + 1)
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
