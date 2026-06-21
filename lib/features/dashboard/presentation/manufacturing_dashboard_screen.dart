import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/manufacturing_dashboard_provider.dart';

class ManufacturingDashboardScreen extends ConsumerStatefulWidget {
  const ManufacturingDashboardScreen({super.key});

  @override
  ConsumerState<ManufacturingDashboardScreen> createState() => _ManufacturingDashboardScreenState();
}

class _ManufacturingDashboardScreenState extends ConsumerState<ManufacturingDashboardScreen> {
  final List<String> _timeframes = ['1M', '3M', 'YTD', '1Y'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(manufacturingDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading dashboard: $error')),
        data: (state) {
          final data = state.data;
          if (data == null) return const Center(child: CircularProgressIndicator());
          
          final kpis = data['kpis'] ?? {};
          final charts = data['charts'] ?? {};
          final widgets = data['widgets'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manufacturing Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('Production & Factory Performance Overview', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
                      ],
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildTimeframeFilters(),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.download, size: 18),
                          label: const Text('Export Report'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fade().slideY(begin: -0.2),
                const SizedBox(height: 32),
                
                // KPI Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                      if (isDesktop) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: GradientKpiCard(title: 'Total Production Orders', value: '${kpis['total_production_orders'] ?? 0}', subtitle: 'All Time', icon: LucideIcons.factory, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/production')).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Released Orders', value: '${kpis['released_orders'] ?? 0}', subtitle: 'Pending Start', icon: LucideIcons.playCircle, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/production?status=Released')).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'In Progress', value: '${kpis['in_progress_orders'] ?? 0}', subtitle: 'Active', icon: LucideIcons.loader, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/production?status=In Progress')).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Completed Orders', value: '${kpis['completed_orders'] ?? 0}', subtitle: 'Finished', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/production?status=Completed')).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: GradientKpiCard(title: 'On Hold Orders', value: '${kpis['on_hold_orders'] ?? 0}', subtitle: 'Blocked', icon: LucideIcons.pauseCircle, gradientColors: [Colors.redAccent, Colors.redAccent], onTap: () => context.go('/production?status=On Hold')).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Ready for Delivery', value: '${kpis['ready_for_delivery_orders'] ?? 0}', subtitle: 'Pending Dispatch', icon: LucideIcons.box, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/production?status=Ready for Delivery')).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Avg Production Time', value: '${(kpis['average_production_time'] ?? 0).toStringAsFixed(1)}h', subtitle: 'Per Order', icon: LucideIcons.clock, gradientColors: [Colors.purple, Colors.purple], onTap: () => {}).animate().fade(delay: 700.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Production Efficiency', value: '${(kpis['production_efficiency_percentage'] ?? 0).toStringAsFixed(1)}%', subtitle: 'Completion Rate', icon: LucideIcons.activity, gradientColors: [Colors.pink, Colors.pink], onTap: () => {}).animate().fade(delay: 800.ms).slideY(begin: 0.1)),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            GradientKpiCard(title: 'Total Production Orders', value: '${kpis['total_production_orders'] ?? 0}', subtitle: 'All Time', icon: LucideIcons.factory, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/production')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Released Orders', value: '${kpis['released_orders'] ?? 0}', subtitle: 'Pending Start', icon: LucideIcons.playCircle, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/production?status=Released')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'In Progress', value: '${kpis['in_progress_orders'] ?? 0}', subtitle: 'Active', icon: LucideIcons.loader, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/production?status=In Progress')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Completed Orders', value: '${kpis['completed_orders'] ?? 0}', subtitle: 'Finished', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/production?status=Completed')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'On Hold Orders', value: '${kpis['on_hold_orders'] ?? 0}', subtitle: 'Blocked', icon: LucideIcons.pauseCircle, gradientColors: [Colors.redAccent, Colors.redAccent], onTap: () => context.go('/production?status=On Hold')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Ready for Delivery', value: '${kpis['ready_for_delivery_orders'] ?? 0}', subtitle: 'Pending Dispatch', icon: LucideIcons.box, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/production?status=Ready for Delivery')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Avg Production Time', value: '${(kpis['average_production_time'] ?? 0).toStringAsFixed(1)}h', subtitle: 'Per Order', icon: LucideIcons.clock, gradientColors: [Colors.purple, Colors.purple], onTap: () => {}),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Production Efficiency', value: '${(kpis['production_efficiency_percentage'] ?? 0).toStringAsFixed(1)}%', subtitle: 'Completion Rate', icon: LucideIcons.activity, gradientColors: [Colors.pink, Colors.pink], onTap: () => {}),
                          ],
                        );
                      }
                  }
                ),

                const SizedBox(height: 32),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildProductionTrendChart(context, charts).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildProductionStatusDistribution(context, charts).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildProductionTrendChart(context, charts).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildProductionStatusDistribution(context, charts).animate().fade(delay: 600.ms),
                    ],
                  ),
                  
                const SizedBox(height: 32),

                _buildStageAnalyticsTable(context, widgets).animate().fade(delay: 650.ms),

                const SizedBox(height: 32),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildProductionQueue(context, widgets).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildOrdersOnHold(context, widgets).animate().fade(delay: 800.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildProductionQueue(context, widgets).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildOrdersOnHold(context, widgets).animate().fade(delay: 800.ms),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeframeFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _timeframes.map((tf) {
          final isSelected = ref.watch(manufacturingDashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(manufacturingDashboardNotifierProvider.notifier).setTimeframe(tf),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
              ),
              child: Text(
                tf,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductionTrendChart(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['production_trend_by_month'] as List<dynamic>? ?? [];
    if (data.isEmpty) {
      return const PremiumCard(
        padding: EdgeInsets.all(24.0),
        child: SizedBox(height: 300, child: Center(child: Text('No production data available.'))),
      );
    }

    final spots = data.asMap().entries.map((e) {
      final val = (e.value['value'] as num).toDouble();
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Production Orders Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Text(data[value.toInt()]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.indigo,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.indigo.withOpacity(0.1),
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

  Widget _buildProductionStatusDistribution(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['production_status_distribution'] as List<dynamic>? ?? [];
    if (data.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data.isNotEmpty 
                    ? data.map<double>((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) > 0
                        ? data.map<double>((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.5
                        : 100
                    : 100),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem('${data[group.x]['label']}\n${rod.toY.toInt()}', const TextStyle(color: Colors.white));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(data[value.toInt()]['label'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value['value'] as num).toDouble(),
                        color: Colors.indigo.withOpacity(1 - (e.key * 0.15).clamp(0, 0.8)),
                        width: 32,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageAnalyticsTable(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['stage_analytics'] as List<dynamic>? ?? [];

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Production Stage Analytics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
             const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No stage analytics data available.")))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                columns: const [
                  DataColumn(label: Text('Stage')),
                  DataColumn(label: Text('Orders')),
                  DataColumn(label: Text('Avg Duration (h)')),
                  DataColumn(label: Text('Delayed Orders')),
                ],
                rows: list.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['stage_name'] ?? '')),
                      DataCell(Text('${item['order_count'] ?? 0}')),
                      DataCell(Text('${(item['average_duration'] ?? 0).toStringAsFixed(1)}')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (item['delayed_orders'] ?? 0) > 0 ? Colors.red.shade50 : Colors.transparent,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text('${item['delayed_orders'] ?? 0}', style: TextStyle(color: (item['delayed_orders'] ?? 0) > 0 ? Colors.red : Colors.black87)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductionQueue(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['current_production_queue'] as List<dynamic>? ?? [];

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Production Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/production?status=In Progress'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No active production orders."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['order_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['product'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['current_stage'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text(item['status'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
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

  Widget _buildOrdersOnHold(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['orders_on_hold'] as List<dynamic>? ?? [];

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Orders On Hold', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/production?status=On Hold'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No orders currently on hold."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['order_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['product'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['current_stage'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        Text(item['status'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
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
}
