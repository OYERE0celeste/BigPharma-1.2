import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prescription_provider.dart';
import '../widgets/bp_theme.dart';
import 'prescription_detail_page.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrescriptions());
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _loadPrescriptions(forceRefresh: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentStatus {
    switch (_tabController.index) {
      case 0: return 'pending';
      case 1: return 'validated';
      case 2: return 'rejected';
      default: return 'pending';
    }
  }

  void _loadPrescriptions({bool forceRefresh = true}) {
    final authProvider = context.read<AuthProvider>();
    context.read<PrescriptionProvider>().loadPrescriptions(
      authProvider: authProvider,
      status: _currentStatus,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Traitement des Ordonnances',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BpColors.textPrimary,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _loadPrescriptions(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualiser'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: BpColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BpColors.border),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: BpColors.primary,
            unselectedLabelColor: BpColors.textSecondary,
            indicatorColor: BpColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'En attente'),
              Tab(text: 'Validées'),
              Tab(text: 'Refusées'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BpSurfaceCard(
            padding: EdgeInsets.zero,
            child: Consumer<PrescriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: BpColors.error),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!, style: TextStyle(color: BpColors.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadPrescriptions(forceRefresh: true),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final items = _tabController.index == 0
                    ? provider.pendingPrescriptions
                    : _tabController.index == 1
                        ? provider.validatedPrescriptions
                        : provider.rejectedPrescriptions;

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: BpColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune ordonnance dans cette catégorie',
                          style: TextStyle(fontSize: 16, color: BpColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final order = items[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PrescriptionDetailPage(order: order),
                          ),
                        ).then((_) => _loadPrescriptions(forceRefresh: true));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: BpColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.receipt_long, color: BpColors.primary, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Commande ${order.orderNumber}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}',
                                        style: TextStyle(color: BpColors.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Client: ${order.clientName}',
                                    style: TextStyle(color: BpColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.chevron_right, color: BpColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
