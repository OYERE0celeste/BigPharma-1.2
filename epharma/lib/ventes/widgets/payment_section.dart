import 'package:epharma/models/activity_model.dart';
import 'package:epharma/widgets/bp_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentSection extends StatefulWidget {
  final double totalAmount;
  final PaymentMethod selectedPaymentMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final ValueChanged<double> onAmountReceivedChanged;
  final double amountReceived;

  const PaymentSection({
    super.key,
    required this.totalAmount,
    required this.selectedPaymentMethod,
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
    _selectedPaymentMethod = widget.selectedPaymentMethod;
    _amountReceivedController = TextEditingController(
      text: widget.amountReceived > 0
          ? widget.amountReceived.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant PaymentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPaymentMethod != widget.selectedPaymentMethod &&
        _selectedPaymentMethod != widget.selectedPaymentMethod) {
      _selectedPaymentMethod = widget.selectedPaymentMethod;
    }
    if (oldWidget.amountReceived != widget.amountReceived) {
      final nextValue = widget.amountReceived > 0
          ? widget.amountReceived.toStringAsFixed(0)
          : '';
      if (_amountReceivedController.text != nextValue) {
        _amountReceivedController.value = TextEditingValue(
          text: nextValue,
          selection: TextSelection.collapsed(offset: nextValue.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    super.dispose();
  }

  Widget _buildPaymentChip(
    PaymentMethod method,
    String label,
    IconData icon,
  ) {
    final selected = _selectedPaymentMethod == method;

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? BpColors.primaryDark : BpColors.textSecondary,
      ),
      label: Text(label),
      selected: selected,
      selectedColor: BpColors.accent,
      backgroundColor: BpColors.surfaceMuted,
      labelStyle: TextStyle(
        color: selected ? BpColors.primaryDark : BpColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? BpColors.accent : BpColors.borderStrong,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedPaymentMethod = method;
        });
        widget.onPaymentMethodChanged(_selectedPaymentMethod);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final changeAmount = widget.amountReceived - widget.totalAmount;
    final isEnough = changeAmount >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: BpColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode de paiement',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BpColors.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentChip(PaymentMethod.cash, 'Cash', Icons.payments),
              _buildPaymentChip(PaymentMethod.card, 'Carte', Icons.credit_card),
              _buildPaymentChip(
                PaymentMethod.mobileMoney,
                'Mobile Money',
                Icons.phone_android,
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _amountReceivedController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: BpColors.textPrimary),
            onChanged: (value) {
              widget.onAmountReceivedChanged(double.tryParse(value) ?? 0);
              setState(() {});
            },
            decoration: BpInputTheme.light(
              label: 'Montant recu',
              hint: 'Entrer le montant recu',
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
          ),
          SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnough
                  ? BpColors.success.withOpacity(0.12)
                  : BpColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEnough ? BpColors.success : BpColors.warning,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monnaie a rendre',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BpColors.textSecondary,
                  ),
                ),
                Text(
                  '${changeAmount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isEnough ? BpColors.success : BpColors.warning,
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
