import 'package:epharma/widgets/app_colors.dart';
import 'package:epharma/widgets/bp_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionSummaryPanel extends StatefulWidget {
  final double subtotal;
  final ValueChanged<double> onDiscountChanged;
  final double discount;
  final double tax;

  const TransactionSummaryPanel({
    super.key,
    required this.subtotal,
    required this.onDiscountChanged,
    required this.discount,
    required this.tax,
  });

  @override
  State<TransactionSummaryPanel> createState() =>
      _TransactionSummaryPanelState();
}

class _TransactionSummaryPanelState extends State<TransactionSummaryPanel> {
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.discount > 0 ? widget.discount.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant TransactionSummaryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.discount != widget.discount) {
      final nextValue =
          widget.discount > 0 ? widget.discount.toStringAsFixed(0) : '';
      if (_discountController.text != nextValue) {
        _discountController.value = TextEditingValue(
          text: nextValue,
          selection: TextSelection.collapsed(offset: nextValue.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Widget _buildAmountRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: BpColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? BpColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.subtotal - widget.discount + widget.tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BpColors.surface,
        border: Border(top: BorderSide(color: BpColors.border)),
      ),
      child: Column(
        children: [
          _buildAmountRow(
            'Sous-total',
            '${widget.subtotal.toStringAsFixed(0)} FCFA',
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Remise',
                style: TextStyle(fontSize: 12, color: BpColors.textSecondary),
              ),
              Spacer(),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _discountController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: BpColors.textPrimary),
                  onChanged: (value) =>
                      widget.onDiscountChanged(double.tryParse(value) ?? 0),
                  decoration: const InputDecoration(
                    suffixText: ' FCFA',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAmountRow('Taxes', '${widget.tax.toStringAsFixed(0)} FCFA'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: BpColors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BpColors.textPrimary,
                ),
              ),
              Text(
                '${total.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
