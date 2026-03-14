import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_colors.dart';
import '../../providers/supplier_provider.dart';
import '../../models/supplier_model.dart';

class EditSupplierDialog extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierDialog({super.key, required this.supplier});

  @override
  State<EditSupplierDialog> createState() => _EditSupplierDialogState();
}

class _EditSupplierDialogState extends State<EditSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _contactNameController = TextEditingController(
      text: widget.supplier.contactName,
    );
    _phoneController = TextEditingController(text: widget.supplier.phone);
    _emailController = TextEditingController(text: widget.supplier.email);
    _addressController = TextEditingController(text: widget.supplier.address);
    _cityController = TextEditingController(text: widget.supplier.city);
    _countryController = TextEditingController(text: widget.supplier.country);
    _notesController = TextEditingController(text: widget.supplier.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier le fournisseur: ${widget.supplier.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du fournisseur',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du contact',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            if (!RegExp(
                              r'^[+]?[\d\s\-\(\)]{10,}$',
                            ).hasMatch(value)) {
                              return 'Téléphone invalide (min 10 chiffres)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
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
                    onPressed: _saveSupplier,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedSupplier = widget.supplier.copyWith(
          name: _nameController.text,
          contactName: _contactNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          city: _cityController.text,
          country: _countryController.text,
          notes: _notesController.text,
        );

        await context.read<SupplierProvider>().updateSupplier(updatedSupplier);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fournisseur modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
