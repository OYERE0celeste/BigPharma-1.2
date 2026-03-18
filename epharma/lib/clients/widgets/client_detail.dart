import 'package:flutter/material.dart';
import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/app_colors.dart';

class ClientDetailsDialog extends StatelessWidget {
  final Client client;

  const ClientDetailsDialog({required this.client, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 600,
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
                      client.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                    // Personal Information Section
                    _buildSection('Information personnel', [
                      _buildDetailRow('Full Name', client.fullName),
                      _buildDetailRow(
                        'Date of Birth',
                        _formatDate(client.dateOfBirth),
                      ),
                      _buildDetailRow('Gender', client.genderDisplay),
                      _buildDetailRow('Phone', client.phone),
                      _buildDetailRow('Email', client.email),
                      _buildDetailRow('Address', client.address),
                      _buildDetailRow(
                        'Registration Date',
                        _formatDate(client.registrationDate),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Commercial Information Section
                    _buildSection('Commercial Information', [
                      _buildDetailRow(
                        'Total Purchases',
                        '${client.totalPurchases}',
                      ),
                      _buildDetailRow(
                        'Total Amount Spent',
                        '€${client.totalSpent.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Average Basket Value',
                        '€${client.averageBasketValue.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Loyalty Level',
                        client.loyaltyStatus
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                      ),
                      _buildDetailRow(
                        'Last Visit',
                        _formatDate(client.lastVisitDate),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Medical Information Section (if available)
                    if (client.hasMedicalProfile) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          border: Border.all(color: kDangerRed, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.security,
                                  color: kDangerRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'PHARMACIST ACCESS ONLY',
                                  style: TextStyle(
                                    color: kDangerRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Description',
                              client.description.isEmpty
                                  ? 'None available'
                                  : client.description,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Purchase History Section
                    _buildSection('Purchase History', []),
                    const SizedBox(height: 12),
                    _buildPurchaseHistory(client),
                    const SizedBox(height: 20),

                    // Prescription History Section
                    if (client.hasMedicalProfile) ...[
                      _buildSection('Prescription History', []),
                      const SizedBox(height: 12),
                      _buildPrescriptionHistory(client),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory(Client client) {
    final purchases = ClientService.getClientPurchases(client.id);
    return SizedBox(
      height: 180,
      child: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        purchase.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '€${purchase.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(purchase.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${purchase.products.join(', ')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionHistory(Client client) {
    final prescriptions = ClientService.getClientPrescriptions(client.id);
    return SizedBox(
      height: 180,
      child: ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prescription.medicationName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          prescription.status,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kPrimaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${prescription.quantity} - ${_formatDate(prescription.validationDate)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
