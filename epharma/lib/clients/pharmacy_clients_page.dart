import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import '../widgets/app_colors.dart';
import 'widgets/client_detail.dart';
import 'widgets/add_edit_client.dart';
import 'widgets/search_filter_client.dart';
import 'widgets/client_table.dart';

class Purchase {
  final String invoiceNumber;
  final DateTime date;
  final List<String> products;
  final double totalAmount;
  final String paymentMethod;

  Purchase({
    required this.invoiceNumber,
    required this.date,
    required this.products,
    required this.totalAmount,
    required this.paymentMethod,
  });
}

class Prescription {
  final String id;
  final String medicationName;
  final DateTime validationDate;
  final String status;
  final int quantity;

  Prescription({
    required this.id,
    required this.medicationName,
    required this.validationDate,
    required this.status,
    required this.quantity,
  });
}

// =====================================================================
// MOCK SERVICE
// =====================================================================

// Mock service removed as we use ClientProvider with real API

// =====================================================================
// MAIN PAGE
// =====================================================================

class PharmacyClientsPage extends StatefulWidget {
  const PharmacyClientsPage({super.key});

  @override
  State<PharmacyClientsPage> createState() => _PharmacyClientsPageState();
}

class _PharmacyClientsPageState extends State<PharmacyClientsPage> {
  String _searchQuery = '';
  String _filterType = 'all';
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
  }

  List<Client> _getFilteredClients(List<Client> allClients) {
    final q = _searchQuery.trim().toLowerCase();
    var clients = List<Client>.from(allClients);
    if (_filterType != 'all') {
      clients = clients.where((client) {
        switch (_filterType) {
          case 'frequent':
            return client.totalPurchases > 50;
          case 'medical':
            return client.hasMedicalHistory;
          case 'inactive':
            final cutoffDate = DateTime.now().subtract(
              const Duration(days: 30),
            );
            return client.lastVisitDate.isBefore(cutoffDate);
          default:
            return true;
        }
      }).toList();
    }
    if (q.isNotEmpty) {
      clients = clients.where((client) {
        return client.fullName.toLowerCase().contains(q) ||
            client.phone.toLowerCase().contains(q) ||
            client.email.toLowerCase().contains(q);
      }).toList();
    }
    return clients;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return _buildMobileView();
        } else {
          return _buildDesktopView();
        }
      },
    );
  }

  Widget _buildMobileView() {
    final provider = context.watch<ClientProvider>();
    final isLoading = provider.isLoading;
    final error = provider.error;
    final filteredClients = _getFilteredClients(provider.clients);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            SearchAndFilterClient(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  _currentPage = 0;
                });
              },
              onFilterChanged: (filter) {
                setState(() {
                  _filterType = filter;
                  _currentPage = 0;
                });
              },
              onAddClient: () => _showClientFormDialog(null),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(
                child: Text(error, style: const TextStyle(color: Colors.red)),
              )
            else if (filteredClients.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucun client trouvé'),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kPrimaryGreen,
                        child: Text(
                          client.fullName.isNotEmpty
                              ? client.fullName[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(client.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.phone),
                          if (client.hasMedicalHistory)
                            const Chip(
                              label: Text('Antécédents'),
                              backgroundColor: kAccentBlue,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              _showClientDetailsPanel(client);
                              break;
                            case 'edit':
                              _showClientFormDialog(client);
                              break;
                            case 'delete':
                              _showDeleteConfirmation(client);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('Voir'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                      ),
                      onTap: () => _showClientDetailsPanel(client),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView() {
    final provider = context.watch<ClientProvider>();
    final isLoading = provider.isLoading;
    final error = provider.error;
    final filteredClients = _getFilteredClients(provider.clients);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            SearchAndFilterClient(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  _currentPage = 0;
                });
              },
              onFilterChanged: (filter) {
                setState(() {
                  _filterType = filter;
                  _currentPage = 0;
                });
              },
              onAddClient: () => _showClientFormDialog(null),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(
                child: Text(error, style: const TextStyle(color: Colors.red)),
              )
            else if (filteredClients.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucun client trouvé'),
                  ],
                ),
              )
            else
              ClientsTable(
                clients: filteredClients,
                currentPage: _currentPage,
                pageSize: _pageSize,
                onViewDetails: (client) {
                  _showClientDetailsPanel(client);
                },
                onEditClient: (client) {
                  _showClientFormDialog(client);
                },
                onDeleteClient: (client) {
                  _showDeleteConfirmation(client);
                },
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showClientDetailsPanel(Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientDetailsDialog(client: client),
    );
  }

  void _showClientFormDialog(Client? client) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSubmit: (updatedClient) {
          Navigator.pop(context);
          if (client == null || updatedClient.id.isEmpty) {
            _addClient(updatedClient);
          } else {
            _updateClient(updatedClient);
          }
        },
      ),
    );
  }

  Future<void> _addClient(Client client) async {
    try {
      await context.read<ClientProvider>().addClient(client);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client ajouté avec succès.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur ajout client: $error')));
      }
    }
  }

  Future<void> _updateClient(Client client) async {
    try {
      await context.read<ClientProvider>().updateClient(client.id, client);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Client mis à jour.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur mise à jour client: $error')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le client'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${client.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ClientProvider>().deleteClient(client.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${client.fullName} a été supprimé.'),
                    ),
                  );
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur suppression client: $error'),
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: kDangerRed)),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SECTION 5: QUICK ACTIONS
// =====================================================================

/*class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.add_circle,
                label: 'Add Client',
                // ignore: avoid_print
                onTap: () => print('Add client'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.download,
                label: 'Export List',
                // ignore: avoid_print
                onTap: () => print('Export list'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.trending_up,
                label: 'Top Clients',
                // ignore: avoid_print
                onTap: () => print('View top clients'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.print,
                label: 'Print Report',
                // ignore: avoid_print
                onTap: () => print('Print report'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kPrimaryGreen, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
