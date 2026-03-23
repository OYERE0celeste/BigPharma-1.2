import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier_model.dart';
import '../providers/supplier_provider.dart';
import 'widgets/add_supplier_dialog.dart';
import 'widgets/header_supplier.dart';
import 'widgets/list_mobile_supplier.dart';
import 'widgets/search_supplier.dart';
import 'widgets/stats_cards_suppliers.dart';
import 'widgets/table_supplier.dart';
import 'widgets/supplier_info_dialog.dart';
import 'commande_fournisseurs_page.dart';

class PharmacySuppliersPage extends StatelessWidget {
  const PharmacySuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SuppliersPageContent();
  }
}

class SuppliersPageContent extends StatefulWidget {
  const SuppliersPageContent({super.key});

  @override
  State<SuppliersPageContent> createState() => _SuppliersPageContentState();
}

class _SuppliersPageContentState extends State<SuppliersPageContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().loadSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filterSuppliers(SupplierProvider provider) {
    if (_searchQuery.trim().isEmpty) {
      return provider.suppliers;
    }
    return provider.searchSuppliers(_searchQuery);
  }

  void _createSupplierOrder(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierOrderPage(supplier: supplier),
      ),
    );
  }

  void _showSupplierInfo(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => SupplierInfoDialog(supplier: supplier),
    );
  }

  void _showEditSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AddSupplierDialog(supplier: supplier),
    );
  }

  void _deleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer ce fournisseur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<SupplierProvider>().deleteSupplier(
                  supplier.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fournisseur supprimé')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderSupplier(
                  isMobile: isMobile,
                  onAddSupplier: _onAddSupplier,
                ),
                const SizedBox(height: 16),
                SearchSupplier(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                StatsCardsSuppliers(isMobile: isMobile),
                const SizedBox(height: 16),
                Expanded(
                  child: isMobile
                      ? Consumer<SupplierProvider>(
                          builder: (context, provider, child) {
                            final suppliers = _filterSuppliers(provider);
                            return MobileSuppliersList(
                              suppliers: suppliers,
                              onOrder: _createSupplierOrder,
                              onInfo: _showSupplierInfo,
                              onEdit: _showEditSupplier,
                              onDelete: _deleteSupplier,
                            );
                          },
                        )
                      : Consumer<SupplierProvider>(
                          builder: (context, provider, child) {
                            final suppliers = _filterSuppliers(provider);
                            return SupplierTable(
                              suppliers: suppliers,
                              isLoading: provider.isLoading,
                              error: provider.error,
                              onOrder: _createSupplierOrder,
                              onInfo: _showSupplierInfo,
                              onEdit: _showEditSupplier,
                              onDelete: _deleteSupplier,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onAddSupplier() {
    showDialog(
      context: context,
      builder: (context) => const AddSupplierDialog(),
    );
  }
}
