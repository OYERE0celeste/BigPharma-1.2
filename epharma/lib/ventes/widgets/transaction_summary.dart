import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';


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
                'Subtotal',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${widget.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                widget.onDiscountChanged(double.tryParse(value) ?? 0),
            decoration: InputDecoration(
              labelText: 'Discount (\$)',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tax',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${widget.tax.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
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