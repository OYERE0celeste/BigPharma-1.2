import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/client_model.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/bp_theme.dart';
import '../../widgets/common/app_ui.dart';

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
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  Gender? _selectedGender;
  DateTime? _dateOfBirth;
  bool _hasMedicalHistory = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.client?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _addressController = TextEditingController(text: widget.client?.address ?? '');
    _selectedGender = widget.client?.gender;
    _dateOfBirth = widget.client?.dateOfBirth;
    _hasMedicalHistory = widget.client?.hasMedicalHistory ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      maxWidth: 720,
      maxHeight: 860,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppResponsive.tabletBreakpoint;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormHeader(isEditing: widget.client != null),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Information personnelle'),
                      _buildTextField(_fullNameController, 'Nom complet'),
                      const SizedBox(height: 12),
                      _buildPhoneField(),
                      const SizedBox(height: 12),
                      _buildTextField(_emailController, 'Email'),
                      const SizedBox(height: 12),
                      _buildTextField(_addressController, 'Adresse', maxLines: 2),
                      const SizedBox(height: 12),
                      if (isCompact)
                        Column(
                          children: [
                            _buildGenderSelector(),
                            const SizedBox(height: 12),
                            _buildDateOfBirthSelector(),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(child: _buildGenderSelector()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDateOfBirthSelector()),
                          ],
                        ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Antecedents medicaux'),
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
              const SizedBox(height: 20),
              _FormActions(
                onCancel: () => Navigator.pop(context),
                onSave: _submitForm,
              ),
            ],
          );
        },
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
      decoration: BpInputTheme.light(
        label: 'Telephone',
        prefixIcon: Icons.phone_outlined,
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
      decoration: BpInputTheme.light(
        label: label,
        prefixIcon: Icons.text_fields_outlined,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: BpInputTheme.light(
        label: 'Genre',
        prefixIcon: Icons.wc_outlined,
      ),
      items: Gender.values
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender.name)))
          .toList(),
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
        decoration: BpInputTheme.light(
          label: 'Date de naissance',
          prefixIcon: Icons.cake_outlined,
        ),
        child: Text(
          _dateOfBirth != null ? _dateOfBirth.toString().split(' ')[0] : 'Selectionner la date',
        ),
      ),
    );
  }

  void _submitForm() {
    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedGender == null ||
        _dateOfBirth == null) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: BpColors.error,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(phone)) {
      AppScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Telephone invalide (8-15 chiffres)'),
          backgroundColor: BpColors.error,
        ),
      );
      return;
    }

    final client = Client(
      id: widget.client?.id ?? '',
      fullName: _fullNameController.text.trim(),
      phone: phone,
      email: _emailController.text.trim(),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.person_add, color: BpColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'Modifier le client' : 'Ajouter un nouveau client',
              style: BpTextStyles.heading3,
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
      child: Text(title, style: BpTextStyles.heading3),
    );
  }
}

class _FormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _FormActions({
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onSave,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
