import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier_model.dart';
import '../../widgets/app_colors.dart';
import '../../providers/supplier_provider.dart';

class AddSupplierDialog extends StatefulWidget {
  final Supplier? supplier;

  const AddSupplierDialog({super.key, this.supplier});

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    if (supplier != null) {
      _nameController.text = supplier.name;
      _contactNameController.text = supplier.contactName;
      _phoneController.text = supplier.phone;
      _emailController.text = supplier.email;
      _addressController.text = supplier.address;
      _cityController.text = supplier.city;
      _countryController.text = supplier.country;
      _notesController.text = supplier.notes;
    }
  }

  bool get _isEditing => widget.supplier != null;

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
                _isEditing
                    ? 'Modifier le fournisseur'
                    : 'Ajouter un nouveau fournisseur',
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
                              r'^[+]?[\d\s\-\(\)]{8,}$',
                            ).hasMatch(value)) {
                              return 'Téléphone invalide (min 8 chiffres)';
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
                    child: Text(_isEditing ? 'Mettre à jour' : 'Enregistrer'),
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
      final provider = context.read<SupplierProvider>();
      try {
        if (_isEditing && widget.supplier != null) {
          final updatedSupplier = widget.supplier!.copyWith(
            name: _nameController.text,
            contactName: _contactNameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            address: _addressController.text,
            city: _cityController.text,
            country: _countryController.text,
            notes: _notesController.text,
          );
          await provider.updateSupplier(updatedSupplier);
        } else {
          await provider.addSupplier(
            name: _nameController.text,
            contactName: _contactNameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            address: _addressController.text,
            city: _cityController.text,
            country: _countryController.text,
            notes: _notesController.text,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Fournisseur mis à jour avec succès'
                    : 'Fournisseur ajouté avec succès',
              ),
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
