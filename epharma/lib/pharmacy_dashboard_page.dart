import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'widgets/app_colors.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/finance_provider.dart';

class PharmacyDashboardPage extends StatelessWidget {
  const PharmacyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      pageTitle: 'Dashboard',
      child: const DashboardPageContent(),
    );
  }
}

class DashboardPageContent extends StatelessWidget {
  const DashboardPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            TopKPISection(),
            SizedBox(height: 20),
            AlertsAndActivityRow(),
            SizedBox(height: 20),
            QuickActionsSection(),
            SizedBox(height: 20),
            StockAndPerformanceRow(),
            SizedBox(height: 20),
            SystemInfoBar(),
          ],
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
                value: '€${financeProvider.totalRevenue.toStringAsFixed(2)}',
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
                value: '€${financeProvider.netProfit.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.teal,
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 3;
                if (width < 800) crossAxisCount = 1;
                if (width >= 800 && width < 1200) crossAxisCount = 2;

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: kpis.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
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
        if (constraints.maxWidth > 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 1, child: AlertsPanel()),
              SizedBox(width: 20),
              Expanded(flex: 2, child: RecentActivityPanel()),
            ],
          );
        } else {
          return Column(
            children: const [
              AlertsPanel(),
              SizedBox(height: 12),
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
    final alerts = [
      AlertData(
        title: 'Expired medicines',
        count: 0,
        severity: AlertSeverity.critical,
      ),
      AlertData(
        title: 'Critical stock',
        count: 0,
        severity: AlertSeverity.critical,
      ),
      AlertData(
        title: 'Rejected prescriptions',
        count: 0,
        severity: AlertSeverity.warning,
      ),
      AlertData(
        title: 'Failed payments',
        count: 0,
        severity: AlertSeverity.warning,
      ),
      AlertData(
        title: 'Recalled batches',
        count: 0,
        severity: AlertSeverity.warning,
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.report_problem, color: kDangerRed),
                SizedBox(width: 8),
                Text(
                  'Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
    final activities = [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: kAccentBlue),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, _) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final a = activities[index];
                  return ActivityTile(data: a);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityData {
  final String title;
  final String subtitle;
  final String time;

  ActivityData({
    required this.title,
    required this.subtitle,
    required this.time,
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
          backgroundColor: kSoftBlue,
          child: Icon(Icons.event_note, color: kAccentBlue, size: 18),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flash_on, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                int cross = 3;
                if (constraints.maxWidth < 700) cross = 2;
                if (constraints.maxWidth < 420) cross = 1;
                return GridView.count(
                  crossAxisCount: cross,
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      onPressed: () {},
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(action.icon, color: action.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action.label,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
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
        if (constraints.maxWidth > 1000) {
          return Row(
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
              SizedBox(height: 12),
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
    final bestSelling = [];

    final lowStock = [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.inventory_2, color: kPrimaryGreen),
                SizedBox(width: 8),
                Text(
                  'Stock Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Top 5 Best-selling',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...bestSelling.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('• $s'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Low stock products',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...lowStock.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('• $s'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Category distribution',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: const Center(child: Text('Chart placeholder')),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.show_chart, color: kAccentBlue),
                SizedBox(width: 8),
                Text(
                  'Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Sales overview',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: const Center(
                child: Text('Chart placeholder: Today / Week / Prev Week'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Today: €0',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Week: €0', style: TextStyle(fontWeight: FontWeight.w600)),
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
    final now = DateTime.now();
    return Row(
      children: [
        Expanded(
          child: Text(
            'Pharmacy: Pharmacie Centrale • User: Alice Dupont (Pharmacist) • Role: Manager',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        Text(_formatDateTime(now), style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 12),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
