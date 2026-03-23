import 'package:flutter/material.dart';

class FinanceFilterSection extends StatefulWidget {
  final String? selectedType;
  final String? selectedPaymentMethod;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(String?) onTypeChanged;
  final Function(String?) onPaymentMethodChanged;
  final VoidCallback onResetFilters;

  const FinanceFilterSection({
    required this.selectedType,
    required this.selectedPaymentMethod,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onPaymentMethodChanged,
    required this.onResetFilters,
    super.key,
  });

  @override
  State<FinanceFilterSection> createState() => _FinanceFilterSectionState();
}

class _FinanceFilterSectionState extends State<FinanceFilterSection> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres Avancés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Recherche globale',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  hint: const Text('Type de transaction'),
                  value: widget.selectedType,
                  items: [
                        'Vente',
                        'Paiement fournisseur',
                        'Dépense',
                        'Retour',
                        'Approvisionnement',
                      ]
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: widget.onTypeChanged,
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  hint: const Text('Mode de paiement'),
                  value: widget.selectedPaymentMethod,
                  items: ['Espèces', 'Carte', 'Virement']
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: widget.onPaymentMethodChanged,
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: widget.onResetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
