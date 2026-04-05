import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_constants.dart';

class OrderExportWidget extends StatefulWidget {
  final String token;
  const OrderExportWidget({super.key, required this.token});

  @override
  State<OrderExportWidget> createState() => _OrderExportWidgetState();
}

class _OrderExportWidgetState extends State<OrderExportWidget> {
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Exporter les Commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range),
                  label: Text(_startDate == null ? 'Période' : 'Dates sélectionnées'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('Statut'),
                  value: _status,
                  onChanged: (val) => setState(() => _status = val),
                  items: ['pending', 'validated', 'preparing', 'delivered', 'cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _triggerExport(),
            icon: const Icon(Icons.download),
            label: const Text('Télécharger CSV'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _triggerExport() async {
    String url = '${ApiConstants.baseUrl}/orders/export?token=${widget.token}';
    if (_status != null) url += '&status=$_status';
    if (_startDate != null) url += '&startDate=${_startDate!.toIso8601String()}';
    if (_endDate != null) url += '&endDate=${_endDate!.toIso8601String()}';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible de lancer l'export.")));
      }
    }
  }
}
