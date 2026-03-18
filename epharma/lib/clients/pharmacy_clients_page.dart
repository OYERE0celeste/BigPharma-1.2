import 'package:flutter/material.dart';
import '../models/client_model.dart';
import 'services/client_api_service.dart';
import '../widgets/app_colors.dart';
import 'widgets/header_client.dart';
import 'widgets/client_detail.dart';
import 'widgets/add_edit_client.dart';
import 'widgets/search_filter_client.dart';
import 'widgets/client_table.dart';
import '../main_layout.dart';

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

class ClientService {
  static final List<Client> _mockClients = [];

  static List<Client> getAllClients() => _mockClients;

  static List<Client> getFilteredClients(String filterType) {
    switch (filterType) {
      case 'frequent':
        return _mockClients.where((c) => c.totalPurchases > 50).toList();
      case 'medical':
        return _mockClients.where((c) => c.hasMedicalProfile).toList();
      case 'inactive':
        final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
        return _mockClients
            .where((c) => c.lastVisitDate.isBefore(cutoffDate))
            .toList();
      default:
        return _mockClients;
    }
  }

  static List<Client> searchClients(String query) {
    final q = query.toLowerCase();
    return _mockClients
        .where(
          (c) =>
              c.fullName.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              c.email.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<Purchase> getClientPurchases(String clientId) {
    return [];
  }

  static List<Prescription> getClientPrescriptions(String clientId) {
    return [];
  }
}

// =====================================================================
// MAIN PAGE
// =====================================================================

class PharmacyClientsPage extends StatefulWidget {
  const PharmacyClientsPage({super.key});

  @override
  State<PharmacyClientsPage> createState() => _PharmacyClientsPageState();
}

class _PharmacyClientsPageState extends State<PharmacyClientsPage> {
  List<Client> _allClients = [];
  List<Client> _filteredClients = [];
  String _searchQuery = '';
  String _filterType = 'all';
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _allClients = await ClientApiService.getAllClients();
      _applyFilters();
    } catch (error) {
      setState(() {
        _error = 'Erreur de chargement des clients : $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();
    var clients = List<Client>.from(_allClients);
    if (_filterType != 'all') {
      clients = clients.where((client) {
        switch (_filterType) {
          case 'frequent':
            return client.totalPurchases > 50;
          case 'medical':
            return client.hasMedicalProfile;
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
    setState(() {
      _filteredClients = clients;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      pageTitle: 'Clients',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            return _buildMobileView();
          } else {
            return _buildDesktopView();
          }
        },
      ),
    );
  }

  Widget _buildMobileView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeaderClient(),
            const SizedBox(height: 16),
            SearchAndFilterClient(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFilters();
              },
              onFilterChanged: (filter) {
                setState(() {
                  _filterType = filter;
                });
                _applyFilters();
              },
              onAddClient: () => _showClientFormDialog(null),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else if (_filteredClients.isEmpty)
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
                itemCount: _filteredClients.length,
                itemBuilder: (context, index) {
                  final client = _filteredClients[index];
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeaderClient(),
            const SizedBox(height: 20),
            SearchAndFilterClient(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFilters();
              },
              onFilterChanged: (filter) {
                setState(() {
                  _filterType = filter;
                });
                _applyFilters();
              },
              onAddClient: () => _showClientFormDialog(null),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else if (_filteredClients.isEmpty)
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
                clients: _filteredClients,
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
    setState(() {});
    try {
      final created = await ClientApiService.createClient(client);
      setState(() {
        _allClients.insert(0, created);
        _applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client ajouté avec succès.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur ajout client: $error')));
    } finally {
      setState(() {});
    }
  }

  Future<void> _updateClient(Client client) async {
    setState(() {});
    try {
      final updated = await ClientApiService.updateClient(client.id, client);
      final idx = _allClients.indexWhere((c) => c.id == updated.id);
      if (idx != -1) {
        setState(() {
          _allClients[idx] = updated;
          _applyFilters();
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Client mis à jour.')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur mise à jour client: $error')),
      );
    } finally {
      setState(() {});
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
              setState(() {});
              try {
                await ClientApiService.deleteClient(client.id);
                setState(() {
                  _allClients.removeWhere((c) => c.id == client.id);
                  _applyFilters();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${client.fullName} a été supprimé.')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur suppression client: $error')),
                );
              } finally {
                setState(() {});
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
