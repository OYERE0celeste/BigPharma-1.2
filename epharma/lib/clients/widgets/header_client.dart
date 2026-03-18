import 'package:flutter/material.dart';
//import 'widgets/header_section.dart';

// =====================================================================
// SECTION 1: HEADER & ACTION BAR
// =====================================================================

class HeaderClient extends StatelessWidget {
  const HeaderClient({super.key});

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
        /*Text(
          'Manage customer profiles and medical records',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),*/
      ],
    );
  }
}
