import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/delivery_dashboard_provider.dart';

class DeliveryDashboardScreen extends ConsumerStatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  ConsumerState<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends ConsumerState<DeliveryDashboardScreen> {
  final List<String> _timeframes = ['1M', '3M', 'YTD', '1Y'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(deliveryDashboardNotifierProvider);

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
          final readiness = data['readiness'] ?? {};

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
                        Text('Delivery Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('Logistics & Fulfillment Overview', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
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
                                Expanded(child: GradientKpiCard(title: 'Total Deliveries', value: '${kpis['total_deliveries'] ?? 0}', subtitle: 'All Time', icon: LucideIcons.truck, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/delivery')).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Scheduled', value: '${kpis['scheduled_deliveries'] ?? 0}', subtitle: 'Pending Dispatch', icon: LucideIcons.calendar, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/delivery?status=Scheduled')).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'In Transit', value: '${kpis['in_transit_deliveries'] ?? 0}', subtitle: 'On the way', icon: LucideIcons.mapPin, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/delivery?status=In Transit')).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Delivered Orders', value: '${kpis['delivered_orders'] ?? 0}', subtitle: 'Completed', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/delivery?status=Delivered')).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: GradientKpiCard(title: 'Today\'s Deliveries', value: '${kpis['todays_deliveries'] ?? 0}', subtitle: 'Due Today', icon: LucideIcons.calendarDays, gradientColors: [Colors.deepPurple, Colors.deepPurple], onTap: () => {}).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Delivery Success Rate', value: '${(kpis['delivery_success_rate'] ?? 0).toStringAsFixed(2)}%', subtitle: 'Success vs Cancelled', icon: LucideIcons.activity, gradientColors: [Colors.teal, Colors.teal], onTap: () => {}).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Cancelled Deliveries', value: '${kpis['cancelled_deliveries'] ?? 0}', subtitle: 'Failed/Cancelled', icon: LucideIcons.xCircle, gradientColors: [Colors.redAccent, Colors.redAccent], onTap: () => context.go('/delivery?status=Cancelled')).animate().fade(delay: 700.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Ready For Delivery', value: '${readiness['ready_for_delivery_orders'] ?? 0}', subtitle: 'Awaiting Schedule', icon: LucideIcons.box, gradientColors: [Colors.pink, Colors.pink], onTap: () => context.go('/production?status=Ready for Delivery')).animate().fade(delay: 800.ms).slideY(begin: 0.1)),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            GradientKpiCard(title: 'Total Deliveries', value: '${kpis['total_deliveries'] ?? 0}', subtitle: 'All Time', icon: LucideIcons.truck, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/delivery')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Scheduled', value: '${kpis['scheduled_deliveries'] ?? 0}', subtitle: 'Pending Dispatch', icon: LucideIcons.calendar, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/delivery?status=Scheduled')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'In Transit', value: '${kpis['in_transit_deliveries'] ?? 0}', subtitle: 'On the way', icon: LucideIcons.mapPin, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/delivery?status=In Transit')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Delivered Orders', value: '${kpis['delivered_orders'] ?? 0}', subtitle: 'Completed', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/delivery?status=Delivered')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Today\'s Deliveries', value: '${kpis['todays_deliveries'] ?? 0}', subtitle: 'Due Today', icon: LucideIcons.calendarDays, gradientColors: [Colors.deepPurple, Colors.deepPurple], onTap: () => {}),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Delivery Success Rate', value: '${(kpis['delivery_success_rate'] ?? 0).toStringAsFixed(2)}%', subtitle: 'Success vs Cancelled', icon: LucideIcons.activity, gradientColors: [Colors.teal, Colors.teal], onTap: () => {}),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Cancelled Deliveries', value: '${kpis['cancelled_deliveries'] ?? 0}', subtitle: 'Failed/Cancelled', icon: LucideIcons.xCircle, gradientColors: [Colors.redAccent, Colors.redAccent], onTap: () => context.go('/delivery?status=Cancelled')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Ready For Delivery', value: '${readiness['ready_for_delivery_orders'] ?? 0}', subtitle: 'Awaiting Schedule', icon: LucideIcons.box, gradientColors: [Colors.pink, Colors.pink], onTap: () => context.go('/production?status=Ready for Delivery')),
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
                      Expanded(flex: 2, child: _buildDeliveryTrendChart(context, charts).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildDeliveryStatusDistribution(context, charts).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildDeliveryTrendChart(context, charts).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildDeliveryStatusDistribution(context, charts).animate().fade(delay: 600.ms),
                    ],
                  ),

                const SizedBox(height: 32),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildUpcomingDeliveries(context, widgets).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildDelayedDeliveries(context, widgets).animate().fade(delay: 800.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildUpcomingDeliveries(context, widgets).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildDelayedDeliveries(context, widgets).animate().fade(delay: 800.ms),
                    ],
                  ),
                  
                const SizedBox(height: 32),
                
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildPendingAcknowledgements(context, widgets).animate().fade(delay: 900.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentlyDelivered(context, widgets).animate().fade(delay: 1000.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildPendingAcknowledgements(context, widgets).animate().fade(delay: 900.ms),
                      const SizedBox(height: 24),
                      _buildRecentlyDelivered(context, widgets).animate().fade(delay: 1000.ms),
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
          final isSelected = ref.watch(deliveryDashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(deliveryDashboardNotifierProvider.notifier).setTimeframe(tf),
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

  Widget _buildDeliveryTrendChart(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['monthly_delivery_trend'] as List<dynamic>? ?? [];
    if (data.isEmpty) {
      return const PremiumCard(
        padding: EdgeInsets.all(24.0),
        child: SizedBox(height: 300, child: Center(child: Text('No delivery trend data available.'))),
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
          Text('Monthly Delivery Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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

  Widget _buildDeliveryStatusDistribution(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['delivery_status_distribution'] as List<dynamic>? ?? [];
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

  Widget _buildUpcomingDeliveries(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['upcoming_deliveries'] as List<dynamic>? ?? [];

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
                Text('Upcoming Deliveries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/delivery?status=Scheduled'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No upcoming deliveries."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['delivery_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer_name'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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

  Widget _buildDelayedDeliveries(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['delayed_deliveries'] as List<dynamic>? ?? [];

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
                Text('Delayed Deliveries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/delivery'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No delayed deliveries."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['delivery_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer_name'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
  
  Widget _buildPendingAcknowledgements(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['pending_customer_acknowledgements'] as List<dynamic>? ?? [];

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
                Text('Pending Acknowledgements', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No pending acknowledgements."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['delivery_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer_name'] ?? ''),
                    trailing: const Icon(LucideIcons.clock, color: Colors.orange, size: 20),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentlyDelivered(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['recently_delivered_orders'] as List<dynamic>? ?? [];

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
                Text('Recently Delivered', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/delivery?status=Delivered'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No recent deliveries."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['delivery_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer_name'] ?? ''),
                    trailing: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
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
