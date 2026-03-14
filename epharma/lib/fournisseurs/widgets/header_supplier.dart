import 'package:flutter/material.dart';
import '../../widgets/app_colors.dart';

class HeaderSupplier extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onAddSupplier;

  const HeaderSupplier({super.key, required this.isMobile, required this.onAddSupplier});

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobileHeader() : _buildDesktopHeader();
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fournisseurs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddSupplier,
            icon: const Icon(Icons.add),
            label: const Text('Nouveau fournisseur'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Fournisseurs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: onAddSupplier,
          icon: const Icon(Icons.add),
          label: const Text('Nouveau fournisseur'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
