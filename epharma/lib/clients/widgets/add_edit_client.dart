import 'package:epharma/models/client_model.dart';
import 'package:epharma/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  Gender? _selectedGender;
  DateTime? _dateOfBirth;
  bool _hasMedicalHistory = false;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(
      text: widget.client?.fullName ?? '',
    );
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.client?.address ?? '',
    );

    _selectedGender = widget.client?.gender;
    _dateOfBirth = widget.client?.dateOfBirth;
    _hasMedicalHistory = widget.client?.hasMedicalHistory ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FormHeader(isEditing: widget.client != null),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Information personnelle'),
                    _buildTextField(_fullNameController, 'Nom complet'),
                    const SizedBox(height: 12),
                    _buildPhoneField(),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, 'Addresse'),
                    const SizedBox(height: 12),
                    _buildGenderSelector(),
                    const SizedBox(height: 12),
                    _buildDateOfBirthSelector(),

                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('Antécédents médicaux'),
                      value: _hasMedicalHistory,
                      onChanged: (value) {
                        setState(() {
                          _hasMedicalHistory = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _FormActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      decoration: const InputDecoration(
        labelText: 'Téléphone',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Genre',
        border: OutlineInputBorder(),
      ),
      items: Gender.values.map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildDateOfBirthSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _dateOfBirth = date;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _dateOfBirth != null
              ? _dateOfBirth.toString().split(' ')[0]
              : 'Selectionner la date',
        ),
      ),
    );
  }

  void _submitForm() {
    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedGender == null ||
        _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: kDangerRed,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Téléphone invalide (8-15 chiffres, chiffres uniquement)',
          ),
          backgroundColor: kDangerRed,
        ),
      );
      return;
    }

    final client = Client(
      id: widget.client?.id ?? '',
      fullName: _fullNameController.text.trim(),
      phone: phone,
      address: _addressController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _selectedGender!,
      hasMedicalHistory: _hasMedicalHistory,
    );

    widget.onSubmit(client);
  }
}

class _FormHeader extends StatelessWidget {
  final bool isEditing;

  const _FormHeader({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.person_add, color: kPrimaryGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEditing ? 'Modifier le client' : 'Ajouter un nouveau client',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FormActions extends StatelessWidget {
  final BuildContext context;

  const _FormActions(this.context);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Access the state to call _submitForm
              final state = context
                  .findAncestorStateOfType<_ClientFormDialogState>();
              state?._submitForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
