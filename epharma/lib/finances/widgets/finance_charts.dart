import 'package:epharma/providers/finance_provider.dart';
import 'package:epharma/services/finance_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
//import '/providers/finance_provider.dart';
//import '../services/finance_service.dart';

class FinanceCharts extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const FinanceCharts({
    required this.startDate,
    required this.endDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final chartData = financeProvider.getRevenueVsExpensesData(
      startDate: startDate,
      endDate: endDate,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyse Graphique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: chartData.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune donnée financière disponible pour le moment',
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY:
                            chartData
                                .map(
                                  (row) => [
                                    row['revenue'] as double,
                                    row['expenses'] as double,
                                  ].reduce((a, b) => a > b ? a : b),
                                )
                                .reduce((a, b) => a > b ? a : b) *
                            1.15,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < chartData.length) {
                                  final date =
                                      chartData[value.toInt()]['date']
                                          as DateTime;
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      DateFormat('dd/MM').format(date),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 72,
                              interval: chartData.isEmpty ? 1 : null,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    FinanceService.formatAmount(value),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: chartData.asMap().entries.map((entry) {
                          final revenue = entry.value['revenue'] as double;
                          final expenses = entry.value['expenses'] as double;
                          return BarChartGroupData(
                            x: entry.key,
                            barsSpace: 8,
                            barRods: [
                              BarChartRodData(
                                toY: revenue,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Colors.greenAccent, Colors.green],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              BarChartRodData(
                                toY: expenses,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Colors.redAccent, Colors.red],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date =
                                  chartData[group.x.toInt()]['date']
                                      as DateTime;
                              final label = rodIndex == 0
                                  ? 'Revenus'
                                  : 'Dépenses';
                              return BarTooltipItem(
                                '${DateFormat('dd/MM/yyyy').format(date)}\n$label : ${FinanceService.formatAmount(rod.toY)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                            getTooltipColor: (group) => Colors.black87,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Revenus (Entrées)'),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Dépenses'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
