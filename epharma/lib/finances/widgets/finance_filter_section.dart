import 'package:flutter/material.dart';

import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_ui.dart';

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
  late final TextEditingController _searchController;

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
  void didUpdateWidget(covariant FinanceFilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: BpSpacing.radiusLg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

          Widget searchField({required bool fullWidth}) {
            return SizedBox(
              width: fullWidth ? double.infinity : 320,
              height: 54,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: BpColors.textPrimary),
                decoration: BpInputTheme.light(
                  label: 'Recherche',
                  hint: 'Recherche globale',
                  prefixIcon: Icons.search,
                  showLabel: false,
                ),
                onChanged: widget.onSearchChanged,
              ),
            );
          }

          Widget dropdownField({
            required bool fullWidth,
            required String? value,
            required String hint,
            required List<String> items,
            required ValueChanged<String?> onChanged,
          }) {
            return SizedBox(
              width: fullWidth ? double.infinity : 220,
              height: 54,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: value,
                dropdownColor: BpColors.surface,
                decoration: BpInputTheme.light(
                  label: hint,
                  hint: hint,
                  showLabel: false,
                ),
                style: const TextStyle(
                  color: BpColors.textPrimary,
                  fontSize: 14,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            );
          }

          Widget resetButton({required bool fullWidth}) {
            return SizedBox(
              width: fullWidth ? double.infinity : 180,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: widget.onResetFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Réinitialiser'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtres avancés', style: BpTextStyles.heading3),
              const SizedBox(height: 16),
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField(fullWidth: true),
                    const SizedBox(height: 12),
                    dropdownField(
                      fullWidth: true,
                      value: widget.selectedType,
                      hint: 'Type de transaction',
                      items: const ['Vente', 'Retour', 'Approvisionnement'],
                      onChanged: widget.onTypeChanged,
                    ),
                    const SizedBox(height: 12),
                    dropdownField(
                      fullWidth: true,
                      value: widget.selectedPaymentMethod,
                      hint: 'Mode de paiement',
                      items: const ['Espèces', 'Carte', 'Virement'],
                      onChanged: widget.onPaymentMethodChanged,
                    ),
                    const SizedBox(height: 12),
                    resetButton(fullWidth: true),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: searchField(fullWidth: false)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: dropdownField(
                        fullWidth: false,
                        value: widget.selectedType,
                        hint: 'Type de transaction',
                        items: const ['Vente', 'Retour', 'Approvisionnement'],
                        onChanged: widget.onTypeChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: dropdownField(
                        fullWidth: false,
                        value: widget.selectedPaymentMethod,
                        hint: 'Mode de paiement',
                        items: const ['Espèces', 'Carte', 'Virement'],
                        onChanged: widget.onPaymentMethodChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 180, child: resetButton(fullWidth: false)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
