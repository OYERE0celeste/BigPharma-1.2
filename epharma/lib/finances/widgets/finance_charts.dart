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
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < chartData.length) {
                            final date =
                                chartData[value.toInt()]['date'] as DateTime;
                            return Text(DateFormat('dd/MM').format(date));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(FinanceService.formatAmount(value));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['revenue'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['expenses'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 3,
                      child: ColoredBox(color: Colors.green),
                    ),
                    SizedBox(width: 8),
                    Text('Revenus'),
                  ],
                ),
                SizedBox(width: 32),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 3,
                      child: ColoredBox(color: Colors.red),
                    ),
                    SizedBox(width: 8),
                    Text('Dépenses'),
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
