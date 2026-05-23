import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/bp_theme.dart';
import '../../widgets/detail_widgets.dart';

class ClientDetailsDialog extends StatelessWidget {
  final Client client;

  const ClientDetailsDialog({required this.client, super.key});

  @override
  Widget build(BuildContext context) {
    final purchases = ClientService.getClientPurchases(client.id);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 760),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BpColors.surfaceStrong, BpColors.cardBg],
          ),
          border: Border.all(color: BpColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BpColors.accent.withOpacity(0.16),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: const Border(
                    bottom: BorderSide(color: BpColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.fullName, style: BpTextStyles.heading2),
                          const SizedBox(height: 6),
                          Text(
                            'Fiche détaillée du client',
                            style: BpTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: BpColors.textPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          DetailInfoTile(
                            icon: Icons.cake_rounded,
                            label: 'Date de naissance',
                            value: _formatDate(client.dateOfBirth),
                          ),
                          DetailInfoTile(
                            icon: Icons.people_rounded,
                            label: 'Genre',
                            value: client.genderDisplay,
                          ),
                          DetailInfoTile(
                            icon: Icons.phone_rounded,
                            label: 'Téléphone',
                            value: client.phone,
                          ),
                          DetailInfoTile(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: client.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      DetailSectionCard(
                        title: 'Informations personnelles',
                        subtitle: 'Coordonnées et historique d’inscription',
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            DetailInfoTile(
                              icon: Icons.home_rounded,
                              label: 'Adresse',
                              value: client.address,
                            ),
                            DetailInfoTile(
                              icon: Icons.calendar_today_rounded,
                              label: 'Inscription',
                              value: _formatDate(client.registrationDate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      DetailSectionCard(
                        title: 'Informations commerciales',
                        subtitle:
                            'Vue d’ensemble du comportement d’achat et du profil client.',
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            DetailMetricCard(
                              icon: Icons.shopping_bag_rounded,
                              label: 'Total achats',
                              value: '${client.totalPurchases}',
                              tone: BpColors.accent,
                            ),
                            DetailMetricCard(
                              icon: Icons.attach_money_rounded,
                              label: 'Montant total',
                              value:
                                  '${client.totalSpent.toStringAsFixed(0)} FCFA',
                              tone: BpColors.warning,
                            ),
                            DetailMetricCard(
                              icon: Icons.auto_graph_rounded,
                              label: 'Panier moyen',
                              value:
                                  '${client.averageBasketValue.toStringAsFixed(0)} FCFA',
                              tone: BpColors.primaryLight,
                            ),
                            DetailMetricCard(
                              icon: Icons.star_rounded,
                              label: 'Fidélité',
                              value: client.loyaltyStatus
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              tone: BpColors.success,
                            ),
                          ],
                        ),
                      ),
                      if (client.hasMedicalHistory) ...[
                        const SizedBox(height: 18),
                        DetailSectionCard(
                          title: 'Informations médicales',
                          subtitle: 'Contenu réservé au personnel autorisé.',
                          child: Text(
                            client.description.isEmpty
                                ? 'Aucune information médicale disponible.'
                                : client.description,
                            style: BpTextStyles.body,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      DetailSectionCard(
                        title: 'Historique des achats',
                        subtitle: 'Dernières commandes du client.',
                        child: purchases.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  'Aucun historique disponible.',
                                  style: BpTextStyles.body,
                                ),
                              )
                            : Column(
                                children: purchases.map((purchase) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: BpColors.surface.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(
                                        BpSpacing.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: BpColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              purchase.invoiceNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: BpColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              _formatDate(purchase.date),
                                              style: const TextStyle(
                                                color: BpColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 8,
                                          children: purchase.products
                                              .map(
                                                (productName) => DetailPill(
                                                  icon: Icons
                                                      .medical_services_rounded,
                                                  label: productName,
                                                  foreground:
                                                      BpColors.textPrimary,
                                                  background: BpColors.surface
                                                      .withOpacity(0.5),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${purchase.totalAmount.toStringAsFixed(0)} FCFA',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: BpColors.accent,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Paiement : ${purchase.paymentMethod}',
                                          style: BpTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
