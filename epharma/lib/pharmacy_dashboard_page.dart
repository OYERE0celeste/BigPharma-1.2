import 'package:epharma/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/app_colors.dart';
import 'providers/product_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/client_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/activity_provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<SalesProvider>().loadSales();
      context.read<FinanceProvider>().initialize();
      context.read<ClientProvider>().loadClients();
      context.read<ActivityProvider>().loadActivities();
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
              children: const [
                TopKPISection(),
                SizedBox(height: 24),
                AlertsAndActivityRow(),
                SizedBox(height: 24),
                QuickActionsSection(),
                SizedBox(height: 24),
                StockAndPerformanceRow(),
                SizedBox(height: 24),
                SystemInfoBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar moved to `app_sidebar.dart` (reuse `AppSidebar` widget)

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
                title: "Today's revenue",
                value: '${financeProvider.totalRevenue.toStringAsFixed(0)} FCFA',
                icon: Icons.attach_money,
                color: kPrimaryGreen,
              ),
              KPIData(
                title: 'Sales today',
                value: '${salesProvider.totalSalesCount}',
                icon: Icons.shopping_cart,
                color: kAccentBlue,
              ),
              KPIData(
                title: 'Out of stock',
                value: '${productProvider.outOfStockCount}',
                icon: Icons.warning,
                color: kDangerRed,
              ),
              KPIData(
                title: 'Expired',
                value: '${productProvider.expiredCount}',
                icon: Icons.event_busy,
                color: Colors.redAccent,
              ),
              KPIData(
                title: 'Near Exp.',
                value: '${productProvider.nearExpirationCount}',
                icon: Icons.event_note,
                color: Colors.orangeAccent,
              ),
              KPIData(
                title: 'Low stock',
                value: '${productProvider.lowStockCount}',
                icon: Icons.warning_amber,
                color: kWarningOrange,
              ),
              KPIData(
                title: 'Total products',
                value: '${productProvider.totalProducts}',
                icon: Icons.inventory,
                color: Colors.purple,
              ),
              KPIData(
                title: 'Net profit',
                value: '${financeProvider.netProfit.toStringAsFixed(0)} FCFA',
                icon: Icons.trending_up,
                color: Colors.teal,
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                
                // Dynamic grid configuration
                int crossAxisCount;
                double childAspectRatio;
                
                if (width < 600) {
                  crossAxisCount = 2; // 2 columns on mobile
                  childAspectRatio = 1.3; // More square on mobile
                } else if (width < 900) {
                  crossAxisCount = 3; // 3 columns on small tablets
                  childAspectRatio = 1.4;
                } else if (width < 1200) {
                  crossAxisCount = 4; // 4 columns on large tablets
                  childAspectRatio = 1.5;
                } else {
                  crossAxisCount = 4; // 4 columns on desktop
                  childAspectRatio = 2.0;
                }

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
                      onTap: () {
                        // navigate to details
                      },
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

  KPIData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        if (!isSmall)
                          Icon(Icons.arrow_forward_ios, 
                               color: Colors.grey[300], 
                               size: 14),
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
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
        title: 'Expired medicines',
        count: productProvider.expiredCount,
        severity: AlertSeverity.critical,
      ),
      AlertData(
        title: 'Critical stock',
        count: productProvider.outOfStockCount,
        severity: AlertSeverity.critical,
      ),
      AlertData(
        title: 'Low stock alerts',
        count: productProvider.lowStockCount,
        severity: AlertSeverity.warning,
      ),
      AlertData(
        title: 'Near expiration',
        count: productProvider.nearExpirationCount,
        severity: AlertSeverity.warning,
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kDangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.report_problem, color: kDangerRed, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...alerts.map((a) => AlertTile(data: a)),
          ],
        ),
      ),
    );
  }
}

enum AlertSeverity { critical, warning }

class AlertData {
  final String title;
  final int count;
  final AlertSeverity severity;

  AlertData({required this.title, required this.count, required this.severity});
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
            child: Text(data.title, style: const TextStyle(fontSize: 14)),
          ),
          if (data.count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
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
    );
  }
}

class RecentActivityPanel extends StatelessWidget {
  const RecentActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ActivityProvider>().activities.take(10).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: kAccentBlue, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320, minHeight: 150),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: activities.length,
                separatorBuilder: (_, _) => Divider(height: 24, color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (context, index) {
                  final a = activities[index];
                  return ActivityTile(
                    data: ActivityData(
                      title: a.typeLabel,
                      subtitle: '${a.clientOrSupplierName} - ${a.productName}',
                      time: _formatTime(a.dateTime),
                      icon: a.typeIcon,
                      color: a.typeColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localDt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${localDt.day}/${localDt.month}';
  }
}

class ActivityData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  ActivityData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class ActivityTile extends StatelessWidget {
  final ActivityData data;

  const ActivityTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                data.subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          data.time,
          style: const TextStyle(color: Colors.black45, fontSize: 12),
        ),
      ],
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
        label: 'Add Product',
        color: kPrimaryGreen,
      ),
      QuickAction(
        icon: Icons.point_of_sale,
        label: 'Register Sale',
        color: kAccentBlue,
      ),
      QuickAction(
        icon: Icons.person_add,
        label: 'Add Client',
        color: Colors.purple,
      ),
      QuickAction(
        icon: Icons.check_circle,
        label: 'Validate Prescription',
        color: Colors.teal,
      ),
      QuickAction(
        icon: Icons.inventory,
        label: 'Manage Stock',
        color: Colors.brown,
      ),
      QuickAction(
        icon: Icons.bar_chart,
        label: 'View Full Reports',
        color: Colors.indigo,
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
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
                  children: actions
                      .map((a) => QuickActionButton(action: a))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;

  QuickAction({required this.icon, required this.label, required this.color});
}

class QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const QuickActionButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: action.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
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
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[300], size: 16),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, color: kPrimaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Stock Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Top 5 Best-selling',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (bestSelling.isEmpty)
              const Text('Aucun produit disponible', style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              ...bestSelling.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: kPrimaryGreen),
                      const SizedBox(width: 8),
                      Text(s, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Low stock products',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (lowStock.isEmpty)
              const Text('Aucun produit en rupture', style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              ...lowStock.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: kWarningOrange),
                      const SizedBox(width: 8),
                      Text(s, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Category distribution',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: categories.isEmpty
                  ? const Center(child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)))
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart, color: kAccentBlue, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Sales overview (Derniers 7 jours)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: sales.isEmpty
                  ? const Center(child: Text('Aucune donnée de vente'))
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
                                    style: const TextStyle(fontSize: 10),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aujourd\'hui: ${todaySales.toStringAsFixed(0)} fcfa',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Semaine: ${weekSales.toStringAsFixed(0)} fcfa',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
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
                'Pharmacy: ${authProvider.company?.name ?? "..."}',
                style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            'User: ${authProvider.user?.fullName ?? "..."} (${authProvider.user?.role.toUpperCase() ?? "..."})',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            _formatDateTime(now),
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
