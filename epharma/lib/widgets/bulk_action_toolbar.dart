import 'package:flutter/material.dart';

class BulkActionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final Function(String) onAction;

  const BulkActionToolbar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount éléments sélectionnés',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => onAction('delete'),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            label: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
          TextButton.icon(
            onPressed: () => onAction('export'),
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            label: const Text('Exporter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
