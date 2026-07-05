import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/report_tabs.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reports Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Customers'),
            Tab(text: 'Inventory'),
            Tab(text: 'Production'),
            Tab(text: 'Finance'),
            Tab(text: 'Delivery'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SalesTab(),
          CustomersTab(),
          InventoryTab(),
          ProductionTab(),
          FinanceTab(),
          DeliveryTab(),
        ],
      ),
    );
  }
}

class SalesTab extends StatelessWidget {
  const SalesTab({super.key});

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
              Expanded(child: ReportKpiCard(title: 'Total Revenue', value: '₹1,245,000', trend: '+12%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Orders Won', value: '342', trend: '+5%', isPositive: true)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Average Order Value', value: '₹3,640', trend: '-2%', isPositive: false)),
              SizedBox(width: 24),
              Expanded(child: ReportKpiCard(title: 'Win Rate', value: '68%', trend: '+4%', isPositive: true)),
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
                Text('Sales Performance (YTD)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Text(months[value.toInt()], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 120000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 150000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 180000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 140000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 220000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 280000, color: theme.colorScheme.primary, width: 24, borderRadius: BorderRadius.circular(4))]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          )
        ],
      ),
    );
  }
}
