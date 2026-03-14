import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class SearchAndFilterClient extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback onAddClient;

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