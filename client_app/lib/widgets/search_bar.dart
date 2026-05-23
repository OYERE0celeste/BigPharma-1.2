import 'package:flutter/material.dart';

import 'bp_theme.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.primary,
    this.controller,
    this.onChanged,
  });

  final Color primary;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher un médicament...',
        hintStyle: const TextStyle(fontSize: 16, color: BpColors.textHint),
        prefixIcon: Icon(Icons.search_rounded, color: primary),
        filled: true,
        fillColor: BpColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: BpColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
      ),
    );
  }
}
