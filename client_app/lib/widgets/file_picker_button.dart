import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilePickerButton extends StatelessWidget {
  final String label;
  final PlatformFile? selectedFile;
  final void Function(PlatformFile?) onFileSelected;

  const FilePickerButton({
    super.key,
    required this.label,
    required this.selectedFile,
    required this.onFileSelected,
  });

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    onFileSelected(result.files.first);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _pickFile(context),
          icon: const Icon(Icons.attach_file),
          label: Text(label),
        ),
        if (selectedFile != null) ...[
          const SizedBox(height: 8),
          Text(
            'Fichier sélectionné : ${selectedFile!.name}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ],
    );
  }
}
