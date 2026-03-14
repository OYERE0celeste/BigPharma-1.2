import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
import '../activites/activity_register_page.dart';
import 'widgets/header_client.dart';
import 'widgets/search_filter_client.dart';
import 'widgets/client_table.dart';
import 'widgets/client_detail.dart';
import 'widgets/add_edit_client.dart';

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
  late List<Client> _displayedClients;
  List<Client> _allClients = [];
  String _searchQuery = '';
  String _filterType = 'all';
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _allClients = ClientService.getAllClients();
    _displayedClients = _allClients;
  }

  void _updateFilters() {
    List<Client> filtered = ClientService.getFilteredClients(_filterType);
    if (_searchQuery.isNotEmpty) {
      filtered = ClientService.searchClients(_searchQuery);
    }
    setState(() {
      _displayedClients = filtered;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var displayedClients = _displayedClients;
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedLabel: 'Clients',
            callbacks: {
              'Dashboard': () =>
                  Navigator.of(context).pushReplacementNamed('/'),
              'Stock': () =>
                  Navigator.of(context).pushReplacementNamed('/products'),
              'Sales': () =>
                  Navigator.of(context).pushReplacementNamed('/sales'),
              'Clients': () {},
              'Activity': () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PharmacyActivityRegisterPage(),
                ),
              ),
            },
          ),
          Expanded(
            child: SafeArea(
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
                        _updateFilters();
                      },
                      onFilterChanged: (filter) {
                        setState(() {
                          _filterType = filter;
                        });
                        _updateFilters();
                      },
                      onAddClient: () => _showClientFormDialog(null),
                    ),
                    const SizedBox(height: 20),
                    ClientsTable(
                      clients: _displayedClients,
                      currentPage: _currentPage,
                      pageSize: _pageSize,
                      onViewDetails: (client) {
                        setState(() {});
                        _showClientDetailsPanel(client );
                      },
                      onEditClient: (client) {
                        _showClientFormDialog(client as Client?);
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
                    //const QuickActionsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          _updateFilters();
        },
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${client.fullName} a été supprimé.')),
              );
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
