import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class PrescriptionBanner extends StatelessWidget {
  final bool isVerified;
  final VoidCallback onAttach;
  final ValueChanged<bool> onVerificationToggle;

  const PrescriptionBanner({
    super.key,
    required this.isVerified,
    required this.onAttach,
    required this.onVerificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: kDangerRed, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: kDangerRed, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This cart contains prescription-required items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kDangerRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAttach,
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text('Attach Prescription'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kDangerRed),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verified', style: TextStyle(fontSize: 11)),
                  value: isVerified,
                  onChanged: (value) => onVerificationToggle(value ?? false),
                  activeColor: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}