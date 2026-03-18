import 'package:epharma/models/activity_model.dart';
import 'package:flutter/material.dart';

class PaymentSection extends StatefulWidget {
  final double totalAmount;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final ValueChanged<double> onAmountReceivedChanged;
  final double amountReceived;

  const PaymentSection({
    super.key,
    required this.totalAmount,
    required this.onPaymentMethodChanged,
    required this.onAmountReceivedChanged,
    required this.amountReceived,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  late TextEditingController _amountReceivedController;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _amountReceivedController = TextEditingController(
      text: widget.amountReceived.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeAmount = widget.amountReceived - widget.totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text(
            ' Methode de Paiement',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SegmentedButton<PaymentMethod>(
            segments: const [
              ButtonSegment(
                value: PaymentMethod.cash,
                label: Text('Cash'),
                icon: Icon(Icons.payments),
              ),
              ButtonSegment(
                value: PaymentMethod.card,
                label: Text('Carte'),
                icon: Icon(Icons.credit_card),
              ),
              ButtonSegment(
                value: PaymentMethod.mobileMoney,
                label: Text('Mobile Money'),
                icon: Icon(Icons.phone_android),
              ),
            ],
            selected: {_selectedPaymentMethod},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedPaymentMethod = newSelection.first;
              });
              widget.onPaymentMethodChanged(_selectedPaymentMethod);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountReceivedController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.onAmountReceivedChanged(double.tryParse(value) ?? 0);
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Montant Reçu (\$)',
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: changeAmount > 0
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: changeAmount > 0 ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${changeAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: changeAmount > 0
                        ? Colors.green.shade700
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}