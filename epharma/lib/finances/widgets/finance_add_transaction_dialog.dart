import 'package:epharma/models/finance_model.dart';
import 'package:flutter/material.dart';
//import '../models/finance_model.dart';

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
  late final _amountController = TextEditingController();
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
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter une Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                value: _isIncome,
                                decoration: const InputDecoration(
                                  labelText: 'Type de transaction',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Entrée'),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('Sortie'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _isIncome = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Montant',
                                  border: OutlineInputBorder(),
                                  prefixText: 'fcfa',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer un montant';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Montant invalide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Référence',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une référence';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _sourceController,
                          decoration: const InputDecoration(
                            labelText: 'Source',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _paymentMethodController,
                          decoration: const InputDecoration(
                            labelText: 'Mode de paiement',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _employeeController,
                          decoration: const InputDecoration(
                            labelText: 'Employé',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
}
