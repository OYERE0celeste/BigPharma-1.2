import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../widgets/bp_theme.dart';

class LotCard extends StatelessWidget {
  final Lot lot;

  const LotCard({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    final status = _lotStatusData(lot.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface.withOpacity(0.62),
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        border: Border.all(color: BpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lot ${lot.lotNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disponible: ${lot.quantityAvailable} / ${lot.quantity}',
                      style: BpTextStyles.body,
                    ),
                  ],
                ),
              ),
              _LotBadge(
                label: status.label,
                color: status.color,
                icon: status.icon,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LotInfo(
                  icon: Icons.calendar_month_rounded,
                  label: 'Fabrication',
                  value: _formatDate(lot.manufacturingDate),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LotInfo(
                  icon: Icons.event_busy_rounded,
                  label: 'Expiration',
                  value: _formatDate(lot.expirationDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LotInfo(
            icon: Icons.payments_rounded,
            label: 'Cout du lot',
            value: '${lot.costPrice.toStringAsFixed(0)} FCFA',
          ),
        ],
      ),
    );
  }

  _LotStatusData _lotStatusData(LotStatus status) {
    switch (status) {
      case LotStatus.expired:
        return _LotStatusData(
          label: 'Expire',
          color: BpColors.error,
          icon: Icons.error_outline_rounded,
        );
      case LotStatus.nearExpiration:
        return _LotStatusData(
          label: 'Bientot expire',
          color: BpColors.warning,
          icon: Icons.schedule_rounded,
        );
      case LotStatus.active:
        return _LotStatusData(
          label: 'Valide',
          color: BpColors.success,
          icon: Icons.verified_rounded,
        );
    }
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _LotInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LotInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong.withOpacity(0.55),
        borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: BpColors.accent),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BpTextStyles.caption),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: BpColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LotBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _LotBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LotStatusData {
  final String label;
  final Color color;
  final IconData icon;

  const _LotStatusData({
    required this.label,
    required this.color,
    required this.icon,
  });
}
