import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/finance_model.dart';
import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_ui.dart';

class FinanceAddTransactionDialog extends StatefulWidget {
  final Function(FinanceTransactionModel) onTransactionAdded;

  const FinanceAddTransactionDialog({
    required this.onTransactionAdded,
    super.key,
  });

  @override
  State<FinanceAddTransactionDialog> createState() =>
      _FinanceAddTransactionDialogState();
}

class _FinanceAddTransactionDialogState
    extends State<FinanceAddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _referenceController = TextEditingController();
  final _sourceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _employeeController = TextEditingController();

  bool _isIncome = true;

  @override
  void dispose() {
    _typeController.dispose();
    _referenceController.dispose();
    _sourceController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _paymentMethodController.dispose();
    _employeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      maxWidth: 720,
      maxHeight: 760,
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

            Widget amountField() {
              return TextFormField(
                controller: _amountController,
                decoration: BpInputTheme.light(
                  label: 'Montant',
                  prefixIcon: Icons.payments_outlined,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              );
            }

            Widget typeField() {
              return DropdownButtonFormField<bool>(
                value: _isIncome,
                decoration: BpInputTheme.light(
                  label: 'Type de transaction',
                  prefixIcon: Icons.swap_horiz_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: true,
                    child: Text('Entrée (Recette)'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('Sortie (Dépense)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isIncome = value ?? true;
                  });
                },
              );
            }

            Widget textField({
              required TextEditingController controller,
              required String label,
              required IconData icon,
              int maxLines = 1,
              String? helperText,
            }) {
              return TextFormField(
                controller: controller,
                decoration: BpInputTheme.light(
                  label: label,
                  prefixIcon: icon,
                ).copyWith(helperText: helperText),
                maxLines: maxLines,
                validator: (value) {
                  if ((label == 'Type' || label == 'Référence') &&
                      (value == null || value.isEmpty)) {
                    return 'Champ requis';
                  }
                  return null;
                },
              );
            }

            final topRow = isCompact
                ? Column(
                    children: [
                      typeField(),
                      const SizedBox(height: 12),
                      amountField(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: typeField()),
                      const SizedBox(width: 12),
                      Expanded(child: amountField()),
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ajouter une transaction',
                        style: BpTextStyles.heading3,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        topRow,
                        const SizedBox(height: 12),
                        textField(
                          controller: _typeController,
                          label: 'Type',
                          icon: Icons.sell_outlined,
                        ),
                        const SizedBox(height: 12),
                        textField(
                          controller: _referenceController,
                          label: 'Référence',
                          icon: Icons.tag_outlined,
                        ),
                        const SizedBox(height: 12),
                        textField(
                          controller: _sourceController,
                          label: 'Source',
                          icon: Icons.account_tree_outlined,
                        ),
                        const SizedBox(height: 12),
                        textField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        textField(
                          controller: _paymentMethodController,
                          label: 'Mode de paiement',
                          icon: Icons.credit_card_outlined,
                        ),
                        const SizedBox(height: 12),
                        textField(
                          controller: _employeeController,
                          label: 'Employé',
                          icon: Icons.person_outline,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submitForm,
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final transaction = FinanceTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      type: _typeController.text,
      reference: _referenceController.text,
      sourceModule: _sourceController.text,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      isIncome: _isIncome,
      paymentMethod: _paymentMethodController.text,
      employeeName: _employeeController.text,
    );

    widget.onTransactionAdded(transaction);
    Navigator.pop(context);
  }
}
