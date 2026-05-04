import 'package:epharma/widgets/app_colors.dart';
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
      text: widget.discount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.subtotal - widget.discount + widget.tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sous-total',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${widget.subtotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Remise',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _discountController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      widget.onDiscountChanged(double.tryParse(value) ?? 0),
                  decoration: const InputDecoration(
                    suffixText: ' FCFA',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taxes',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${widget.tax.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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