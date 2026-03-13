import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_colors.dart';
import '../activites/pharmacy_activity_register_page.dart';

// =====================================================================
// MOCK DATA MODELS
// =====================================================================

class Client {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime registrationDate;
  final int totalPurchases;
  final double totalSpent;
  final DateTime lastVisitDate;
  final LoyaltyStatus loyaltyStatus;
  final bool hasMedicalProfile;
  final String allergies;
  final String chronicConditions;
  final String currentTreatments;
  final String pharmacistNotes;

  Client({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.registrationDate,
    required this.totalPurchases,
    required this.totalSpent,
    required this.lastVisitDate,
    required this.loyaltyStatus,
    required this.hasMedicalProfile,
    required this.allergies,
    required this.chronicConditions,
    required this.currentTreatments,
    required this.pharmacistNotes,
  });

  double get averageBasketValue =>
      totalSpent / (totalPurchases > 0 ? totalPurchases : 1);
}

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

enum LoyaltyStatus { standard, regular, vip }

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
                    const HeaderSection(),
                    const SizedBox(height: 20),
                    SearchAndFilterSection(
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
                    ClientsTableSection(
                      clients: _displayedClients,
                      currentPage: _currentPage,
                      pageSize: _pageSize,
                      onViewDetails: (client) {
                        setState(() {});
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
// SECTION 1: HEADER & ACTION BAR
// =====================================================================

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clients & Patients',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage customer profiles and medical records',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// =====================================================================
// SECTION: SEARCH & FILTER
// =====================================================================

class SearchAndFilterSection extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback onAddClient;

  const SearchAndFilterSection({
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAddClient,
    super.key,
  });

  @override
  State<SearchAndFilterSection> createState() => _SearchAndFilterSectionState();
}

class _SearchAndFilterSectionState extends State<SearchAndFilterSection> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or email...',
              prefixIcon: const Icon(Icons.search, color: kPrimaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
            onChanged: (query) {
              widget.onSearchChanged(query);
            },
          ),
        ),
        const SizedBox(width: 12),
        DropdownMenu<String>(
          initialSelection: 'all',
          onSelected: (value) {
            if (value != null) {
              setState(() {});
              widget.onFilterChanged(value);
            }
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'all', label: 'All Clients'),
            DropdownMenuEntry(value: 'frequent', label: 'Frequent Buyers'),
            DropdownMenuEntry(value: 'medical', label: 'With Medical Profile'),
            DropdownMenuEntry(value: 'inactive', label: 'Inactive'),
          ],
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Ajouter un nouveau client',
          child: ElevatedButton(
            onPressed: widget.onAddClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Icon(Icons.add),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Exporter la liste des clients',
          child: ElevatedButton(
            onPressed: widget.onAddClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Icon(Icons.download),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Top Clients',
          child: ElevatedButton(
            onPressed: widget.onAddClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Icon(Icons.trending_up),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Imprimer la liste des clients',
          child: ElevatedButton(
            onPressed: widget.onAddClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Icon(Icons.print),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// SECTION 2: CLIENTS TABLE
// =====================================================================

class ClientsTableSection extends StatelessWidget {
  final List<Client> clients;
  final int currentPage;
  final int pageSize;
  final Function(Client) onViewDetails;
  final Function(Client) onEditClient;
  final Function(Client) onDeleteClient;
  final Function(int) onPageChanged;

  const ClientsTableSection({
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
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Purchases')),
              DataColumn(label: Text('Total Spent')),
              DataColumn(label: Text('Last Visit')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Medical Profile')),
              DataColumn(label: Text('Actions')),
            ],
            rows: paginatedClients.map((client) {
              return DataRow(
                onSelectChanged: (_) => onViewDetails(client),
                cells: [
                  DataCell(Text(client.fullName)),
                  DataCell(Text(client.phone)),
                  DataCell(Text(client.email, overflow: TextOverflow.ellipsis)),
                  DataCell(Text(client.totalPurchases.toString())),
                  DataCell(Text('€${client.totalSpent.toStringAsFixed(2)}')),
                  DataCell(Text(_formatDate(client.lastVisitDate))),
                  DataCell(_buildLoyaltyBadge(client.loyaltyStatus)),
                  DataCell(
                    client.hasMedicalProfile
                        ? const Tooltip(
                            message: 'Medical profile available',
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
                          tooltip: 'View Details',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => onEditClient(client),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDeleteClient(client),
                          tooltip: 'Delete',
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

  Widget _buildLoyaltyBadge(LoyaltyStatus status) {
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// =====================================================================
// SECTION 3: CLIENT DETAILS PANEL
// =====================================================================

class ClientDetailsDialog extends StatelessWidget {
  final Client client;

  const ClientDetailsDialog({required this.client, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: kPrimaryGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      client.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSection('Personal Information', [
                      _buildDetailRow('Full Name', client.fullName),
                      _buildDetailRow(
                        'Date of Birth',
                        _formatDate(client.dateOfBirth),
                      ),
                      _buildDetailRow('Gender', client.gender),
                      _buildDetailRow('Phone', client.phone),
                      _buildDetailRow('Email', client.email),
                      _buildDetailRow('Address', client.address),
                      _buildDetailRow(
                        'Registration Date',
                        _formatDate(client.registrationDate),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Commercial Information Section
                    _buildSection('Commercial Information', [
                      _buildDetailRow(
                        'Total Purchases',
                        '${client.totalPurchases}',
                      ),
                      _buildDetailRow(
                        'Total Amount Spent',
                        '€${client.totalSpent.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Average Basket Value',
                        '€${client.averageBasketValue.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Loyalty Level',
                        client.loyaltyStatus
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                      ),
                      _buildDetailRow(
                        'Last Visit',
                        _formatDate(client.lastVisitDate),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Medical Information Section (if available)
                    if (client.hasMedicalProfile) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          border: Border.all(color: kDangerRed, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.security,
                                  color: kDangerRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'PHARMACIST ACCESS ONLY',
                                  style: TextStyle(
                                    color: kDangerRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Allergies',
                              client.allergies.isEmpty
                                  ? 'None known'
                                  : client.allergies,
                            ),
                            _buildDetailRow(
                              'Chronic Conditions',
                              client.chronicConditions.isEmpty
                                  ? 'None'
                                  : client.chronicConditions,
                            ),
                            _buildDetailRow(
                              'Current Treatments',
                              client.currentTreatments.isEmpty
                                  ? 'None'
                                  : client.currentTreatments,
                            ),
                            _buildDetailRow(
                              'Pharmacist Notes',
                              client.pharmacistNotes.isEmpty
                                  ? 'No notes'
                                  : client.pharmacistNotes,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Purchase History Section
                    _buildSection('Purchase History', []),
                    const SizedBox(height: 12),
                    _buildPurchaseHistory(client),
                    const SizedBox(height: 20),

                    // Prescription History Section
                    if (client.hasMedicalProfile) ...[
                      _buildSection('Prescription History', []),
                      const SizedBox(height: 12),
                      _buildPrescriptionHistory(client),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory(Client client) {
    final purchases = ClientService.getClientPurchases(client.id);
    return SizedBox(
      height: 180,
      child: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        purchase.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '€${purchase.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(purchase.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${purchase.products.join(', ')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionHistory(Client client) {
    final prescriptions = ClientService.getClientPrescriptions(client.id);
    return SizedBox(
      height: 180,
      child: ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prescription.medicationName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          prescription.status,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kPrimaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${prescription.quantity} - ${_formatDate(prescription.validationDate)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// =====================================================================
// SECTION 4: ADD / EDIT CLIENT FORM
// =====================================================================

class ClientFormDialog extends StatefulWidget {
  final Client? client;
  final Function(Client) onSubmit;

  const ClientFormDialog({
    required this.client,
    required this.onSubmit,
    super.key,
  });

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _allergiesController;
  late TextEditingController _chronicConditionsController;
  late TextEditingController _currentTreatmentsController;
  late TextEditingController _pharmacistNotesController;

  String _selectedGender = 'Femme';
  LoyaltyStatus _selectedLoyaltyStatus = LoyaltyStatus.standard;
  bool _hasMedicalProfile = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.client?.fullName ?? '',
    );
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _addressController = TextEditingController(
      text: widget.client?.address ?? '',
    );
    _dobController = TextEditingController(
      text: widget.client != null
          ? '${widget.client!.dateOfBirth.day}/${widget.client!.dateOfBirth.month}/${widget.client!.dateOfBirth.year}'
          : '',
    );
    _allergiesController = TextEditingController(
      text: widget.client?.allergies ?? '',
    );
    _chronicConditionsController = TextEditingController(
      text: widget.client?.chronicConditions ?? '',
    );
    _currentTreatmentsController = TextEditingController(
      text: widget.client?.currentTreatments ?? '',
    );
    _pharmacistNotesController = TextEditingController(
      text: widget.client?.pharmacistNotes ?? '',
    );

    if (widget.client != null) {
      _selectedGender = widget.client!.gender;
      _selectedLoyaltyStatus = widget.client!.loyaltyStatus;
      _hasMedicalProfile = widget.client!.hasMedicalProfile;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    _currentTreatmentsController.dispose();
    _pharmacistNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kPrimaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.client == null
                            ? 'Add New Client'
                            : 'Edit Client',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Data',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dobController,
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth (DD/MM/YYYY)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Femme',
                                  child: Text('Femme'),
                                ),
                                DropdownMenuItem(
                                  value: 'Homme',
                                  child: Text('Homme'),
                                ),
                                DropdownMenuItem(
                                  value: 'Autre',
                                  child: Text('Autre'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value ?? 'Femme';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Commercial Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<LoyaltyStatus>(
                        value: _selectedLoyaltyStatus,
                        decoration: const InputDecoration(
                          labelText: 'Loyalty Status',
                          border: OutlineInputBorder(),
                        ),
                        items: LoyaltyStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.toString().split('.').last.toUpperCase(),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLoyaltyStatus =
                                value ?? LoyaltyStatus.standard;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Has Medical Profile'),
                        value: _hasMedicalProfile,
                        onChanged: (value) {
                          setState(() {
                            _hasMedicalProfile = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_hasMedicalProfile) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kAccentBlue, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medical Information',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _allergiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Allergies',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _chronicConditionsController,
                                decoration: const InputDecoration(
                                  labelText: 'Chronic Conditions',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _currentTreatmentsController,
                                decoration: const InputDecoration(
                                  labelText: 'Current Treatments',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _pharmacistNotesController,
                                decoration: const InputDecoration(
                                  labelText: 'Pharmacist Notes',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newClient = Client(
                                  id:
                                      widget.client?.id ??
                                      DateTime.now().toString(),
                                  fullName: _fullNameController.text,
                                  phone: _phoneController.text,
                                  email: _emailController.text,
                                  address: _addressController.text,
                                  dateOfBirth: DateTime.now(),
                                  gender: _selectedGender,
                                  registrationDate:
                                      widget.client?.registrationDate ??
                                      DateTime.now(),
                                  totalPurchases:
                                      widget.client?.totalPurchases ?? 0,
                                  totalSpent: widget.client?.totalSpent ?? 0,
                                  lastVisitDate:
                                      widget.client?.lastVisitDate ??
                                      DateTime.now(),
                                  loyaltyStatus: _selectedLoyaltyStatus,
                                  hasMedicalProfile: _hasMedicalProfile,
                                  allergies: _allergiesController.text,
                                  chronicConditions:
                                      _chronicConditionsController.text,
                                  currentTreatments:
                                      _currentTreatmentsController.text,
                                  pharmacistNotes:
                                      _pharmacistNotesController.text,
                                );
                                widget.onSubmit(newClient);
                              }
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
