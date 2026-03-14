import 'package:flutter/material.dart';
import '../../models/client_model.dart';
import '../../widgets/app_colors.dart';

class ClientFormDialog extends StatefulWidget {
  final Client? client;
  final Function(Client) onSubmit;

  const ClientFormDialog({
    required this.client,
    required this.onSubmit,
    super.key,
  });

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _allergiesController;
  late TextEditingController _chronicConditionsController;
  late TextEditingController _currentTreatmentsController;
  late TextEditingController _pharmacistNotesController;

  Gender _selectedGender = Gender.female;
  LoyaltyStatus _selectedLoyaltyStatus = LoyaltyStatus.standard;
  bool _hasMedicalProfile = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.client?.fullName ?? '',
    );
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _addressController = TextEditingController(
      text: widget.client?.address ?? '',
    );
    _dobController = TextEditingController(
      text: widget.client != null
          ? '${widget.client!.dateOfBirth.day}/${widget.client!.dateOfBirth.month}/${widget.client!.dateOfBirth.year}'
          : '',
    );
    _allergiesController = TextEditingController(
      text: widget.client?.allergies ?? '',
    );
    _chronicConditionsController = TextEditingController(
      text: widget.client?.chronicConditions ?? '',
    );
    _currentTreatmentsController = TextEditingController(
      text: widget.client?.currentTreatments ?? '',
    );
    _pharmacistNotesController = TextEditingController(
      text: widget.client?.pharmacistNotes ?? '',
    );

    if (widget.client != null) {
      _selectedGender = widget.client!.gender;
      _selectedLoyaltyStatus = widget.client!.loyaltyStatus;
      _hasMedicalProfile = widget.client!.hasMedicalProfile;
    }
  }

  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    _currentTreatmentsController.dispose();
    _pharmacistNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kPrimaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.client == null
                            ? 'Add New Client'
                            : 'Edit Client',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Data',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      /*TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),*/
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dobController,
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth (DD/MM/YYYY)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<Gender>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: Gender.female,
                                  child: Text('Femme'),
                                ),
                                DropdownMenuItem(
                                  value: Gender.male,
                                  child: Text('Homme'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value ?? Gender.female;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Commercial Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<LoyaltyStatus>(
                        value: _selectedLoyaltyStatus,
                        decoration: const InputDecoration(
                          labelText: 'Loyalty Status',
                          border: OutlineInputBorder(),
                        ),
                        items: LoyaltyStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.toString().split('.').last.toUpperCase(),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLoyaltyStatus =
                                value ?? LoyaltyStatus.standard;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Has Medical Profile'),
                        value: _hasMedicalProfile,
                        onChanged: (value) {
                          setState(() {
                            _hasMedicalProfile = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_hasMedicalProfile) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kAccentBlue, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medical Information',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _allergiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Allergies',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _chronicConditionsController,
                                decoration: const InputDecoration(
                                  labelText: 'Chronic Conditions',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _currentTreatmentsController,
                                decoration: const InputDecoration(
                                  labelText: 'Current Treatments',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _pharmacistNotesController,
                                decoration: const InputDecoration(
                                  labelText: 'Pharmacist Notes',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newClient = Client(
                                  id:
                                      widget.client?.id ??
                                      DateTime.now().toString(),
                                  fullName: _fullNameController.text,
                                  phone: _phoneController.text,
                                  email: _emailController.text,
                                  address: _addressController.text,
                                  dateOfBirth:
                                      _parseDate(_dobController.text) ??
                                      DateTime.now(),
                                  gender: _selectedGender,
                                  registrationDate:
                                      widget.client?.registrationDate ??
                                      DateTime.now(),
                                  totalPurchases:
                                      widget.client?.totalPurchases ?? 0,
                                  totalSpent: widget.client?.totalSpent ?? 0,
                                  lastVisitDate:
                                      widget.client?.lastVisitDate ??
                                      DateTime.now(),
                                  loyaltyStatus: _selectedLoyaltyStatus,
                                  hasMedicalProfile: _hasMedicalProfile,
                                  allergies: _allergiesController.text,
                                  chronicConditions:
                                      _chronicConditionsController.text,
                                  currentTreatments:
                                      _currentTreatmentsController.text,
                                  pharmacistNotes:
                                      _pharmacistNotesController.text,
                                );
                                widget.onSubmit(newClient);
                              }
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
