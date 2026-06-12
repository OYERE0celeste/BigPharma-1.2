import 'package:flutter/material.dart';

import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_ui.dart';

class SearchAndFilterClient extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback? onAddClient;

  const SearchAndFilterClient({
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAddClient,
    super.key,
  });

  @override
  State<SearchAndFilterClient> createState() => _SearchAndFilterClientState();
}

class _SearchAndFilterClientState extends State<SearchAndFilterClient> {
  late final TextEditingController _searchController;
  String _selectedFilter = 'all';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;
        Widget searchField({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 420,
            height: 54,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: BpColors.textPrimary),
              decoration: BpInputTheme.light(
                label: 'Recherche',
                hint: 'Rechercher un client...',
                prefixIcon: Icons.search,
                showLabel: false,
              ),
              onChanged: widget.onSearchChanged,
            ),
          );
        }

        Widget filterField({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 220,
            height: 54,
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              isExpanded: true,
              dropdownColor: BpColors.surface,
              decoration: BpInputTheme.light(
                label: 'Filtre',
                hint: 'Tous',
                showLabel: false,
              ),
              style: TextStyle(
                color: BpColors.textPrimary,
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(
                  value: 'frequent',
                  child: Text('Frequents'),
                ),
                DropdownMenuItem(
                  value: 'medical',
                  child: Text('Medical'),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactifs'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedFilter = value);
                widget.onFilterChanged(value);
              },
            ),
          );
        }

        Widget addButton({required bool fullWidth}) {
          if (widget.onAddClient == null) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: fullWidth ? double.infinity : 200,
            height: 54,
            child: FilledButton.icon(
              onPressed: widget.onAddClient,
              icon: Icon(Icons.add),
              label: Text('Ajouter'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.surfaceStrong,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: BpColors.border),
                ),
              ),
            ),
          );
        }

        Widget refreshButton({required bool fullWidth}) {
          return SizedBox(
            width: fullWidth ? double.infinity : 160,
            height: 54,
            child: FilledButton.icon(
              onPressed: () => widget.onSearchChanged(_searchController.text),
              icon: Icon(Icons.refresh),
              label: Text('Actualiser'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.surfaceMuted,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: BpColors.border),
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('GESTION DES CLIENTS', style: BpTextStyles.heading2),
                    SizedBox(height: 4),
                    Text(
                      'Gerez les clients et leurs profils medicaux',
                      style: TextStyle(
                        color: BpColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 16),
                    searchField(fullWidth: true),
                    SizedBox(height: 12),
                    filterField(fullWidth: true),
                    SizedBox(height: 12),
                    addButton(fullWidth: true),
                    if (widget.onAddClient != null) SizedBox(height: 12),
                    refreshButton(fullWidth: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GESTION DES CLIENTS',
                            style: BpTextStyles.heading2,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gerez les clients et leurs profils medicaux',
                            style: TextStyle(
                              color: BpColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: searchField(fullWidth: false)),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            child: filterField(fullWidth: false),
                          ),
                          const SizedBox(width: 12),
                          if (widget.onAddClient != null) ...[
                            SizedBox(
                              width: 200,
                              child: addButton(fullWidth: false),
                            ),
                            const SizedBox(width: 12),
                          ],
                          SizedBox(
                            width: 160,
                            child: refreshButton(fullWidth: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
