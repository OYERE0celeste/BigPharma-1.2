import 'package:epharma/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/app_colors.dart';
import 'widgets/bp_theme.dart';
import 'widgets/common/app_ui.dart';
import 'providers/product_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/activity_provider.dart';
import 'models/activity_model.dart';
import 'main_layout.dart';

void _navigateToDashboardSection(BuildContext context, String section) {
  MainLayoutScope.maybeOf(context)?.navigateToSection(section);
}

String _resolveActivitySection(ActivityType type) {
  switch (type) {
    case ActivityType.sale:
    case ActivityType.return_:
      return 'Sales';
    case ActivityType.restocking:
    case ActivityType.stockAdjustment:
      return 'Products';
    case ActivityType.userAction:
      return 'Clients';
    case ActivityType.financeAction:
      return 'Finances';
    case ActivityType.order:
      return 'Orders';
    case ActivityType.cancellation:
    case ActivityType.systemAction:
      return 'Dashboard';
  }
}

class PharmacyDashboardPage extends StatelessWidget {
  const PharmacyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPageContent();
  }
}

class DashboardPageContent extends StatefulWidget {
  const DashboardPageContent({super.key});

  @override
  State<DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<DashboardPageContent> {
  void _refreshDashboard({bool forceRefresh = false}) {
    context.read<ProductProvider>().loadProducts(forceRefresh: forceRefresh);
    context.read<SalesProvider>().loadSales(forceRefresh: forceRefresh);
    context.read<FinanceProvider>().initialize(forceRefresh: forceRefresh);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                const TopKPISection(),
                const SizedBox(height: 24),
                const QuickActionsSection(),
                const SizedBox(height: 24),
                const SystemInfoBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final now = DateTime.now();
        final todayLabel = "Aujourd'hui, ${now.day}/${now.month}/${now.year}";

        Widget buildDateBadge() {
          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BpColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BpColors.borderStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: kAccentBlue,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    todayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BpColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget buildRefreshButton({bool stretch = false}) {
          return SizedBox(
            height: 48,
            width: stretch ? double.infinity : null,
            child: FilledButton.icon(
              onPressed: () => _refreshDashboard(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Actualiser'),
              style: FilledButton.styleFrom(
                backgroundColor: BpColors.surfaceMuted,
                foregroundColor: BpColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: BpColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
            ),
          );
        }

        if (constraints.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreeting(context),
              const SizedBox(height: 8),
              Text(
                'Aperçu global de votre activité pharmaceutique',
                style: TextStyle(color: BpColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              buildDateBadge(),
              const SizedBox(height: 12),
              buildRefreshButton(stretch: true),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 4),
                  Text(
                    'Aperçu global de votre activité pharmaceutique',
                    style: const TextStyle(
                      color: BpColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, minWidth: 280),
              child: buildDateBadge(),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 170, child: buildRefreshButton()),
          ],
        );
      },
    );
  }
  Widget _buildGreeting(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    final String name = auth.user?.fullName.split(' ')[0] ?? 'Pharmacien';

    return Text(
      '$greeting, $name ! 👋',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Color(0xFFF2FBF6),
      ),
    );
  }
}

class _DashboardSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _DashboardSectionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: EdgeInsets.zero,
      radius: BpSpacing.radiusXl,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: BpTextStyles.heading3.copyWith(
                      color: BpColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// --------------------------- Top KPI Section ---------------------------
class TopKPISection extends StatelessWidget {
  const TopKPISection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, SalesProvider, FinanceProvider>(
      builder:
          (context, productProvider, salesProvider, financeProvider, child) {
            final kpis = [
              KPIData(
                title: "Chiffre d'affaires aujourd'hui",
                value:
                    '${financeProvider.totalRevenue.toStringAsFixed(0)} FCFA',
                icon: Icons.attach_money,
                color: kPrimaryGreen,
                section: 'Finances',
              ),
              KPIData(
                title: 'Ventes aujourd\'hui',
                value: '${salesProvider.totalSalesCount}',
                icon: Icons.shopping_cart,
                color: kAccentBlue,
                section: 'Sales',
              ),
              KPIData(
                title: 'Rupture de stock',
                value: '${productProvider.outOfStockCount}',
                icon: Icons.warning,
                color: kDangerRed,
                section: 'Products',
              ),
              KPIData(
                title: 'Expirés',
                value: '${productProvider.expiredCount}',
                icon: Icons.event_busy,
                color: Colors.redAccent,
                section: 'Products',
              ),
              KPIData(
                title: 'Bientôt expirés',
                value: '${productProvider.nearExpirationCount}',
                icon: Icons.event_note,
                color: Colors.orangeAccent,
                section: 'Products',
              ),
              KPIData(
                title: 'Stock faible',
                value: '${productProvider.lowStockCount}',
                icon: Icons.warning_amber,
                color: kWarningOrange,
                section: 'Products',
              ),
              KPIData(
                title: 'Total produits',
                value: '${productProvider.totalProducts}',
                icon: Icons.inventory,
                color: Colors.purple,
                section: 'Products',
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = AppResponsive.gridColumns(
                  width,
                  minTileWidth: 220,
                  maxColumns: 4,
                );
                final childAspectRatio = width < 600
                    ? 1.35
                    : width < 1100
                        ? 1.5
                        : 1.85;

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: kpis.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final item = kpis[index];
                    return KPICard(
                      title: item.title,
                      value: item.value,
                      icon: item.icon,
                      color: item.color,
                      onTap: () =>
                          _navigateToDashboardSection(context, item.section),
                    );
                  },
                );
              },
            );
          },
    );
  }
}

class KPIData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String section;

  KPIData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.section,
  });
}

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: EdgeInsets.zero,
      radius: BpSpacing.radiusLg,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 150;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        if (!isSmall)
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: BpColors.textHint,
                            size: 14,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: BpColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: BpColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Alerts & Activity ---------------------------
class AlertsAndActivityRow extends StatelessWidget {
  const AlertsAndActivityRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 3, child: AlertsPanel()),
              SizedBox(width: 20),
              Expanded(flex: 5, child: RecentActivityPanel()),
            ],
          );
        } else {
          return Column(
            children: const [
              AlertsPanel(),
              SizedBox(height: 20),
              RecentActivityPanel(),
            ],
          );
        }
      },
    );
  }
}

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final alerts = [
      AlertData(
        title: 'Médicaments expirés',
        count: productProvider.expiredCount,
        severity: AlertSeverity.critical,
        section: 'Products',
      ),
      AlertData(
        title: 'Stock critique',
        count: productProvider.outOfStockCount,
        severity: AlertSeverity.critical,
        section: 'Products',
      ),
      AlertData(
        title: 'Alertes stock faible',
        count: productProvider.lowStockCount,
        severity: AlertSeverity.warning,
        section: 'Products',
      ),
      AlertData(
        title: 'Date d\'expiration proche',
        count: productProvider.nearExpirationCount,
        severity: AlertSeverity.warning,
        section: 'Products',
      ),
    ];

    return _DashboardSectionCard(
      title: 'Alertes',
      icon: Icons.report_problem,
      accentColor: kDangerRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: alerts.map((a) => AlertTile(data: a)).toList(),
      ),
    );
  }
}

enum AlertSeverity { critical, warning }

class AlertData {
  final String title;
  final int count;
  final AlertSeverity severity;
  final String section;

  AlertData({
    required this.title,
    required this.count,
    required this.severity,
    required this.section,
  });
}

class AlertTile extends StatelessWidget {
  final AlertData data;

  const AlertTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    switch (data.severity) {
      case AlertSeverity.critical:
        indicatorColor = kDangerRed;
        break;
      case AlertSeverity.warning:
        indicatorColor = kWarningOrange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _navigateToDashboardSection(context, data.section),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: BpColors.textPrimary,
                  ),
                ),
              ),
              if (data.count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: indicatorColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.count}',
                    style: TextStyle(
                      color: indicatorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivityPanel extends StatelessWidget {
  const RecentActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = context
        .watch<ActivityProvider>()
        .activities
        .take(10)
        .toList();

    return _DashboardSectionCard(
      title: 'Activité récente',
      icon: Icons.history,
      accentColor: kAccentBlue,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320, minHeight: 150),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: activities.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 24, color: BpColors.border),
          itemBuilder: (context, index) {
            final a = activities[index];
            return ActivityTile(
              data: ActivityData(
                title: a.typeLabel,
                subtitle: '${a.clientOrSupplierName} - ${a.productName}',
                time: _formatTime(a.dateTime),
                icon: a.typeIcon,
                color: a.typeColor,
                section: _resolveActivitySection(a.type),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localDt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return '${localDt.day}/${localDt.month}';
  }
}

class ActivityData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final String section;

  ActivityData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.section,
  });
}

class ActivityTile extends StatelessWidget {
  final ActivityData data;

  const ActivityTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _navigateToDashboardSection(context, data.section),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: data.color.withOpacity(0.12),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BpColors.textPrimary,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: BpColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              data.time,
              style: const TextStyle(color: BpColors.textHint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------- Quick Actions ---------------------------
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        icon: Icons.add_box,
        label: 'Ajouter un produit',
        color: kPrimaryGreen,
        section: 'Products',
      ),
      QuickAction(
        icon: Icons.point_of_sale,
        label: 'Enregistrer une vente',
        color: kAccentBlue,
        section: 'Sales',
      ),
      QuickAction(
        icon: Icons.person_add,
        label: 'Ajouter un client',
        color: Colors.purple,
        section: 'Clients',
      ),
      QuickAction(
        icon: Icons.inventory,
        label: 'Gérer le stock',
        color: Colors.brown,
        section: 'Products',
      ),
      QuickAction(
        icon: Icons.bar_chart,
        label: 'Rapports complets',
        color: Colors.indigo,
        section: 'Finances',
      ),
    ];

    return _DashboardSectionCard(
      title: 'Actions rapides',
      icon: Icons.flash_on,
      accentColor: Colors.amber,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int cross = 3;
          double ratio = 2.5;

          if (width < 500) {
            cross = 1;
            ratio = 4.5;
          } else if (width < 800) {
            cross = 2;
            ratio = 2.8;
          }

          return GridView.count(
            crossAxisCount: cross,
            childAspectRatio: ratio,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: actions.map((a) => QuickActionButton(action: a)).toList(),
          );
        },
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String section;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.section,
  });
}

class QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const QuickActionButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      padding: EdgeInsets.zero,
      radius: BpSpacing.radiusLg,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          onTap: () => _navigateToDashboardSection(context, action.section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(action.icon, color: action.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BpColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: BpColors.textHint,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Stock Summary & Performance ---------------------------
class StockAndPerformanceRow extends StatelessWidget {
  const StockAndPerformanceRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 1, child: StockSummary()),
              SizedBox(width: 20),
              Expanded(flex: 1, child: PerformanceSection()),
            ],
          );
        } else {
          return Column(
            children: const [
              StockSummary(),
              SizedBox(height: 20),
              PerformanceSection(),
            ],
          );
        }
      },
    );
  }
}

class StockSummary extends StatelessWidget {
  const StockSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final bestSelling = products.take(5).map((p) => p.name).toList();
    final lowStock = products
        .where((p) => p.availableStock <= p.lowStockThreshold)
        .take(5)
        .map((p) => p.name)
        .toList();

    final Map<String, int> categories = {};
    for (var p in products) {
      categories[p.category] = (categories[p.category] ?? 0) + 1;
    }
    final List<Color> categoryColors = [
      kPrimaryGreen,
      kAccentBlue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    return _DashboardSectionCard(
      title: 'Aperçu du stock',
      icon: Icons.inventory_2,
      accentColor: kPrimaryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 des meilleures ventes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: BpColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (bestSelling.isEmpty)
            const Text(
              'Aucun produit disponible',
              style: TextStyle(color: BpColors.textSecondary, fontSize: 13),
            )
          else
            ...bestSelling.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: kPrimaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        color: BpColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Produits à stock faible',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: BpColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (lowStock.isEmpty)
            const Text(
              'Aucun produit en rupture',
              style: TextStyle(color: BpColors.textSecondary, fontSize: 13),
            )
          else
            ...lowStock.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: kWarningOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        color: BpColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Répartition par catégorie',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: BpColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.5,
            child: categories.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée',
                      style: TextStyle(color: BpColors.textSecondary),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 25,
                      sections: categories.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final idx = entry.key;
                            final mapEntry = entry.value;
                            return PieChartSectionData(
                              color:
                                  categoryColors[idx % categoryColors.length],
                              value: mapEntry.value.toDouble(),
                              title: '${mapEntry.key}\n(${mapEntry.value})',
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PerformanceSection extends StatelessWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesProvider>().sales;
    final now = DateTime.now();
    final todaySales = sales
        .where(
          (s) =>
              s.dateTime.day == now.day &&
              s.dateTime.month == now.month &&
              s.dateTime.year == now.year,
        )
        .fold(0.0, (sum, s) => sum + s.totalAmount);
    final weekSales = sales
        .where((s) => now.difference(s.dateTime).inDays <= 7)
        .fold(0.0, (sum, s) => sum + s.totalAmount);

    final List<BarChartGroupData> barGroups = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dailyTotal = sales
          .where(
            (s) =>
                s.dateTime.day == date.day &&
                s.dateTime.month == date.month &&
                s.dateTime.year == date.year,
          )
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              color: kPrimaryGreen,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return _DashboardSectionCard(
      title: 'Performance',
      icon: Icons.show_chart,
      accentColor: kAccentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu des ventes (7 derniers jours)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: BpColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.5,
            child: sales.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée de vente',
                      style: TextStyle(color: BpColors.textSecondary),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = now.subtract(
                                Duration(days: 6 - value.toInt()),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: BpColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: barGroups,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aujourd\'hui: ${todaySales.toStringAsFixed(0)} fcfa',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semaine: ${weekSales.toStringAsFixed(0)} fcfa',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: BpColors.textPrimary,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aujourd\'hui: ${todaySales.toStringAsFixed(0)} fcfa',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BpColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Semaine: ${weekSales.toStringAsFixed(0)} fcfa',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BpColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --------------------------- System Info ---------------------------
class SystemInfoBar extends StatelessWidget {
  const SystemInfoBar({super.key});

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final now = DateTime.now();

    return BpSurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      radius: BpSpacing.radiusLg,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pharmacie : ${authProvider.company?.name ?? "..."}',
                style: const TextStyle(
                  color: BpColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'Utilisateur : ${authProvider.user?.fullName ?? "..."} (${authProvider.user?.role.toUpperCase() ?? "..."})',
            style: const TextStyle(color: BpColors.textSecondary, fontSize: 12),
          ),
          Text(
            _formatDateTime(now),
            style: const TextStyle(
              color: BpColors.textSecondary,
              fontSize: 12,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

