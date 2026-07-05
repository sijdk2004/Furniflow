import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

// Shared KPI Card
class ReportKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const ReportKpiCard({super.key, required this.title, required this.value, required this.trend, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    bool startsWithPlus = trend.startsWith('+');
    bool isNegativeGoodLocal = isPositive != startsWithPlus;

    return GradientKpiCard(
      title: title,
      value: value,
      subtitle: trend,
      icon: LucideIcons.barChart2,
      gradientColors: [Colors.blue.shade800, Colors.indigo.shade800],
      isNegativeGood: isNegativeGoodLocal,
    );
  }
}

class CustomersTab extends StatelessWidget {
  const CustomersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ReportKpiCard(title: 'Total Customers', value: '1,204', trend: '+12%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'New Customers', value: '84', trend: '+5%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Churn Rate', value: '2.1%', trend: '-0.4%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Customer LTV', value: '₹14,500', trend: '+8%', isPositive: true)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 400,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Acquisition Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              if (value.toInt() >= 0 && value.toInt() < months.length) return Text(months[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [FlSpot(0, 20), FlSpot(1, 35), FlSpot(2, 40), FlSpot(3, 60), FlSpot(4, 55), FlSpot(5, 84)],
                          isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ReportKpiCard(title: 'Inventory Value', value: '₹8,50,000', trend: '-2.1%', isPositive: false)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Stockouts', value: '3', trend: '-1', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Turnover Rate', value: '4.2', trend: '+0.5', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Scrap Rate', value: '1.8%', trend: '-0.2%', isPositive: true)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 400,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventory Valuation by Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const cats = ['Raw Mat', 'WIP', 'Finished', 'Packaging', 'Spare Parts'];
                              if (value.toInt() >= 0 && value.toInt() < cats.length) return Text(cats[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 350000, color: Colors.indigo, width: 32, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 200000, color: Colors.indigo, width: 32, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 250000, color: Colors.indigo, width: 32, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 30000, color: Colors.indigo, width: 32, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 20000, color: Colors.indigo, width: 32, borderRadius: BorderRadius.circular(4))]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductionTab extends StatelessWidget {
  const ProductionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ReportKpiCard(title: 'Overall Efficiency (OEE)', value: '92%', trend: '+4.5%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Active Orders', value: '45', trend: '+12', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Delayed Orders', value: '2', trend: '-3', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Machine Utilization', value: '88%', trend: '+2%', isPositive: true)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 400,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Production Output Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const weeks = ['W1', 'W2', 'W3', 'W4'];
                              if (value.toInt() >= 0 && value.toInt() < weeks.length) return Text(weeks[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [FlSpot(0, 120), FlSpot(1, 140), FlSpot(2, 110), FlSpot(3, 160)],
                          isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceTab extends StatelessWidget {
  const FinanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ReportKpiCard(title: 'Gross Margin', value: '42.5%', trend: '+2.1%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Operating Costs', value: '₹1,42,800', trend: '-1.5%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Accounts Receivable', value: '₹320K', trend: '-5%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Net Profit', value: '₹1,85,000', trend: '+14%', isPositive: true)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 400,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash Flow Analysis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                              if (value.toInt() >= 0 && value.toInt() < months.length) return Text(months[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 150, color: Colors.teal, width: 16), BarChartRodData(toY: 100, color: Colors.red.shade300, width: 16)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 180, color: Colors.teal, width: 16), BarChartRodData(toY: 120, color: Colors.red.shade300, width: 16)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 140, color: Colors.teal, width: 16), BarChartRodData(toY: 110, color: Colors.red.shade300, width: 16)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 220, color: Colors.teal, width: 16), BarChartRodData(toY: 130, color: Colors.red.shade300, width: 16)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: ReportKpiCard(title: 'On-Time Delivery', value: '94.2%', trend: '+0.8%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Avg Delivery Time', value: '4.5 Days', trend: '-0.5 Days', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Pending Dispatches', value: '18', trend: '-2', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Return Rate', value: '1.2%', trend: '-0.1%', isPositive: true)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 400,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Performance Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              if (value.toInt() >= 0 && value.toInt() < months.length) return Text(months[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [FlSpot(0, 88), FlSpot(1, 90), FlSpot(2, 89), FlSpot(3, 92), FlSpot(4, 93), FlSpot(5, 94.2)],
                          isCurved: true, color: Colors.purple, barWidth: 3, dotData: const FlDotData(show: true),
                        ),
                      ],
                      minY: 80,
                      maxY: 100,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}
