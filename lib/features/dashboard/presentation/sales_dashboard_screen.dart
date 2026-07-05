import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/sales_dashboard_provider.dart';

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  final List<String> _timeframes = ['1M', '3M', 'YTD', '1Y'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(salesDashboardNotifierProvider);

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
                        Text('Sales Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('Sales Performance Overview', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
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
                      final totalRevFormatted = ((kpis['total_sales_revenue'] ?? 0) / 1000).toStringAsFixed(2);
                      final monthlyRevFormatted = ((kpis['monthly_sales_revenue'] ?? 0) / 1000).toStringAsFixed(2);
                      final aovFormatted = (kpis['average_order_value'] ?? 0).toStringAsFixed(2);

                      if (isDesktop) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                 Expanded(child: GradientKpiCard(title: 'Total Revenue', value: '₹${totalRevFormatted}k', subtitle: '+${(kpis['revenue_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.trendingUp, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/sales-orders')).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Sales Orders', value: '${kpis['sales_orders'] ?? 0}', subtitle: '+${(kpis['sales_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.shoppingCart, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/sales-orders?status=active')).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Quotations', value: '${kpis['active_quotations'] ?? 0}', subtitle: '+${(kpis['quotations_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.fileText, gradientColors: [Colors.purple, Colors.purple], onTap: () => context.go('/quotations?status=active')).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Customers', value: '${kpis['total_customers'] ?? 0}', subtitle: '+${(kpis['customers_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.users, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/customers?filter=all')).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: GradientKpiCard(title: 'Approved Quotations', value: '${kpis['approved_quotations'] ?? 0}', subtitle: 'Pending Convert', icon: LucideIcons.checkCircle, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/quotations?status=approved')).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Converted Quotations', value: '${kpis['converted_quotations'] ?? 0}', subtitle: '${kpis['quotation_conversion_rate']?.toStringAsFixed(2) ?? '0.00'}% Rate', icon: LucideIcons.medal, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/quotations?status=converted')).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                Expanded(child: GradientKpiCard(title: 'Average Order Value', value: '₹$aovFormatted', subtitle: 'AOV', icon: LucideIcons.tag, gradientColors: [Colors.lightBlue, Colors.lightBlue], onTap: () => context.go('/sales-orders')).animate().fade(delay: 700.ms).slideY(begin: 0.1)),
                                const SizedBox(width: 16),
                                 Expanded(child: GradientKpiCard(title: 'Monthly Revenue', value: '₹${monthlyRevFormatted}k', subtitle: 'This Month', icon: LucideIcons.indianRupee, gradientColors: [Colors.pink, Colors.pink], onTap: () => context.go('/sales-orders')).animate().fade(delay: 800.ms).slideY(begin: 0.1)),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            GradientKpiCard(title: 'Total Revenue', value: '₹${totalRevFormatted}k', subtitle: '+${(kpis['revenue_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.trendingUp, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/sales-orders')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Sales Orders', value: '${kpis['sales_orders'] ?? 0}', subtitle: '+${(kpis['sales_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.shoppingCart, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/sales-orders')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Quotations', value: '${kpis['active_quotations'] ?? 0}', subtitle: '+${(kpis['quotations_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.fileText, gradientColors: [Colors.purple, Colors.purple], onTap: () => context.go('/quotations')),
                            const SizedBox(height: 16),
                            GradientKpiCard(title: 'Customers', value: '${kpis['total_customers'] ?? 0}', subtitle: '+${(kpis['customers_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.users, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/customers')),
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
                      Expanded(flex: 2, child: _buildRevenueTrendChart(context, charts).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildConversionFunnel(context, charts).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildRevenueTrendChart(context, charts).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildConversionFunnel(context, charts).animate().fade(delay: 600.ms),
                    ],
                  ),
                  
                const SizedBox(height: 32),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildRecentOrdersList(context, widgets).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentQuotationsList(context, widgets).animate().fade(delay: 800.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildRecentOrdersList(context, widgets).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildRecentQuotationsList(context, widgets).animate().fade(delay: 800.ms),
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
          final isSelected = ref.watch(salesDashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(salesDashboardNotifierProvider.notifier).setTimeframe(tf),
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

  Widget _buildRevenueTrendChart(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['monthly_revenue_trend'] as List<dynamic>? ?? [];
    if (data.isEmpty) {
      return const PremiumCard(
        padding: EdgeInsets.all(24.0),
        child: SizedBox(height: 300, child: Center(child: Text('No revenue data available.'))),
      );
    }

    final spots = data.asMap().entries.map((e) {
      final val = (e.value['value'] as num).toDouble();
      return FlSpot(e.key.toDouble(), val / 1000); // show in K
    }).toList();

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Revenue Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                      getTitlesWidget: (value, meta) => Text('₹${value.toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                    color: Colors.teal,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.1),
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

  Widget _buildConversionFunnel(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    final data = charts['quotation_conversion_funnel'] as List<dynamic>? ?? [];
    if (data.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conversion Funnel', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data.isNotEmpty ? (data[0]['value'] as num).toDouble() : 100) * 1.2,
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
                      getTitlesWidget: (value, meta) => Text(data[value.toInt()]['label'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                        color: Colors.blue.withOpacity(1 - (e.key * 0.2)),
                        width: 40 - (e.key * 5.0),
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

  Widget _buildRecentOrdersList(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['recent_sales_orders'] as List<dynamic>? ?? [];

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
                Text('Recent Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/sales-orders'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No recent orders."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['order_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${item['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
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

  Widget _buildRecentQuotationsList(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final list = widgets['recent_quotations'] as List<dynamic>? ?? [];

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
                Text('Recent Quotations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => context.go('/quotations'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty 
              ? const Center(child: Text("No recent quotations."))
              : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['quotation_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['customer'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${item['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
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
