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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'GESTION DES CLIENTS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérez les clients et leurs profils médicaux',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search and Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (query) => widget.onSearchChanged(query),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'all',
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tous')),
                          DropdownMenuItem(
                              value: 'frequent', child: Text('Fréquents')),
                          DropdownMenuItem(
                              value: 'medical', child: Text('Médical')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('Inactifs')),
                        ],
                        onChanged: (value) {
                          if (value != null) widget.onFilterChanged(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onAddClient,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        widget.onSearchChanged(_searchController.text),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Rafraîchir',
                    color: Colors.black54,
                  ),
                ],
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Left: Title and Subtitle
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'GESTION DES CLIENTS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gérez les clients et leurs profils médicaux',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Middle: Search and Filter
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Nom, téléphone ou email...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          onChanged: (query) {
                            widget.onSearchChanged(query);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'all',
                          icon: const Icon(Icons.arrow_drop_down),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Tous les clients'),
                            ),
                            DropdownMenuItem(
                              value: 'frequent',
                              child: Text('Acheteurs fréquents'),
                            ),
                            DropdownMenuItem(
                              value: 'medical',
                              child: Text('Profil médical'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Inactifs'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              widget.onFilterChanged(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Actions
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.onSearchChanged(_searchController.text);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Rafraîchir',
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.onAddClient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Icon(Icons.add),
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
