import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../../../../core/presentation/widgets/drill_down_chart.dart';
import '../data/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _hoveredCategoryIndex = -1;
  int _selectedCategoryIndex = 0;
  String _selectedTimeframe = 'YTD';
  final List<String> _timeframes = ['1M', '3M', 'YTD', '1Y'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(dashboardNotifierProvider);

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
                    Text('CEO Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Business Performance Overview', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
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
            
            // Executive Summary
            _buildExecutiveSummary(context).animate().fade(delay: 50.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),

            // KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                  final totalRevFormatted = ((kpis['total_revenue'] ?? 0) / 1000).toStringAsFixed(2);
                  final monthlyRevFormatted = ((kpis['monthly_revenue'] ?? 0) / 1000).toStringAsFixed(2);

                  if (isDesktop) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: GradientKpiCard(title: 'Total Revenue', value: '\$$totalRevFormatted\k', subtitle: '+${(kpis['revenue_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.trendingUp, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/sales-orders')).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Sales Orders', value: '${kpis['sales_orders'] ?? 0}', subtitle: '+${(kpis['active_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.shoppingCart, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/sales-orders?status=active')).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Quotations', value: '${kpis['active_quotations'] ?? 0}', subtitle: '+${(kpis['quotations_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.fileText, gradientColors: [Colors.purple, Colors.purple], onTap: () => context.go('/quotations?status=active')).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Customers', value: '${kpis['total_customers'] ?? 0}', subtitle: '+${(kpis['customers_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.users, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/customers?filter=all')).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: GradientKpiCard(title: 'Production Orders', value: '${kpis['production_orders'] ?? 0}', subtitle: 'Active', icon: LucideIcons.factory, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/manufacturing?status=active')).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Ready for Delivery', value: '${kpis['ready_for_delivery'] ?? 0}', subtitle: 'Pending', icon: LucideIcons.box, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/delivery?status=ready')).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Delivered Orders', value: '${kpis['delivered_orders'] ?? 0}', subtitle: 'Completed', icon: LucideIcons.truck, gradientColors: [Colors.lightBlue, Colors.lightBlue], onTap: () => context.go('/delivery?status=delivered')).animate().fade(delay: 700.ms).slideY(begin: 0.1)),
                            const SizedBox(width: 16),
                            Expanded(child: GradientKpiCard(title: 'Monthly Revenue', value: '\$$monthlyRevFormatted\k', subtitle: 'This Month', icon: LucideIcons.dollarSign, gradientColors: [Colors.pink, Colors.pink], onTap: () => context.go('/sales-orders')).animate().fade(delay: 800.ms).slideY(begin: 0.1)),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        GradientKpiCard(title: 'Total Revenue', value: '\$$totalRevFormatted\k', subtitle: '+${(kpis['revenue_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.trendingUp, gradientColors: [Colors.teal, Colors.teal], onTap: () => context.go('/sales-orders')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Sales Orders', value: '${kpis['sales_orders'] ?? 0}', subtitle: '+${(kpis['active_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.shoppingCart, gradientColors: [Colors.blue, Colors.blue], onTap: () => context.go('/sales-orders?status=active')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Quotations', value: '${kpis['active_quotations'] ?? 0}', subtitle: '+${(kpis['quotations_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.fileText, gradientColors: [Colors.purple, Colors.purple], onTap: () => context.go('/quotations?status=active')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Customers', value: '${kpis['total_customers'] ?? 0}', subtitle: '+${(kpis['customers_growth'] as num? ?? 0).toStringAsFixed(2)}%', icon: LucideIcons.users, gradientColors: [Colors.orange, Colors.orange], onTap: () => context.go('/customers?filter=all')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Production Orders', value: '${kpis['production_orders'] ?? 0}', subtitle: 'Active', icon: LucideIcons.factory, gradientColors: [Colors.indigo, Colors.indigo], onTap: () => context.go('/manufacturing?status=active')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Ready for Delivery', value: '${kpis['ready_for_delivery'] ?? 0}', subtitle: 'Pending', icon: LucideIcons.box, gradientColors: [Colors.green, Colors.green], onTap: () => context.go('/delivery?status=ready')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Delivered Orders', value: '${kpis['delivered_orders'] ?? 0}', subtitle: 'Completed', icon: LucideIcons.truck, gradientColors: [Colors.lightBlue, Colors.lightBlue], onTap: () => context.go('/delivery?status=delivered')),
                        const SizedBox(height: 16),
                        GradientKpiCard(title: 'Monthly Revenue', value: '\$$monthlyRevFormatted\k', subtitle: 'This Month', icon: LucideIcons.dollarSign, gradientColors: [Colors.pink, Colors.pink], onTap: () => context.go('/sales-orders')),
                      ],
                    );
                  }
              }
            ),

            const SizedBox(height: 32),

            // Main Charts Section (Trend + Category)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRevenueTrendChart(context, charts).animate().fade(delay: 500.ms)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildRevenueByCategoryChart(context, charts).animate().fade(delay: 600.ms)),
                ],
              )
            else
              Column(
                children: [
                  _buildRevenueTrendChart(context, charts).animate().fade(delay: 500.ms),
                  const SizedBox(height: 24),
                  _buildRevenueByCategoryChart(context, charts).animate().fade(delay: 600.ms),
                ],
              ),
              
            const SizedBox(height: 32),

            // Secondary Charts Section (Drill Down + Cash Flow)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildDrillDownChart(context, charts).animate().fade(delay: 700.ms)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildRecentOrdersList(context, widgets).animate().fade(delay: 800.ms)),
                ],
              )
            else
              Column(
                children: [
                  _buildDrillDownChart(context, charts).animate().fade(delay: 700.ms),
                  const SizedBox(height: 24),
                  _buildRecentOrdersList(context, widgets).animate().fade(delay: 800.ms),
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
          final isSelected = ref.watch(dashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(dashboardNotifierProvider.notifier).setTimeframe(tf),
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

  Widget _buildExecutiveSummary(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.purple.shade900]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.yellowAccent),
              const SizedBox(width: 8),
              Text('Executive AI Insights', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const InsightPill(text: 'Revenue grew by 14.2% this month.', icon: Icons.trending_up, color: Colors.greenAccent),
              const InsightPill(text: 'Gross margin improved to 42.5%.', icon: Icons.trending_up, color: Colors.greenAccent),
              const InsightPill(text: 'B2B office furniture contracts are driving growth.', icon: Icons.star, color: Colors.yellowAccent),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildRevenueTrendChart(BuildContext context, Map charts) {
    final hierarchicalData = charts['hierarchical_sales_trend'] as List<dynamic>? ?? [];
    if (hierarchicalData.isEmpty) {
      return const PremiumCard(
        padding: EdgeInsets.all(24.0),
        child: SizedBox(height: 300, child: Center(child: Text('No revenue data available.'))),
      );
    }
    return DrillDownBarChart(rawData: hierarchicalData);
  }

  Widget _buildRevenueByCategoryChart(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text('Revenue by Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text('Tap to Drill Down', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                              _hoveredCategoryIndex = -1;
                              return;
                            }
                            _hoveredCategoryIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            if (event is FlTapUpEvent) {
                              if (_selectedCategoryIndex == _hoveredCategoryIndex) {
                                _selectedCategoryIndex = -1;
                              } else {
                                _selectedCategoryIndex = _hoveredCategoryIndex;
                              }
                            }
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        _buildPieSection(0, Colors.teal, 45.0, '45%'),
                        _buildPieSection(1, Colors.blue, 35.0, '35%'),
                        _buildPieSection(2, Colors.orange, 20.0, '20%'),
                      ],
                    ),
                  ),
                ),
                Text('Total\n100%', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildLegendItem(context, 0, 'Office Furniture', Colors.teal, '\$111,825'),
              const SizedBox(height: 12),
              _buildLegendItem(context, 1, 'Home Living', Colors.blue, '\$86,975'),
              const SizedBox(height: 12),
              _buildLegendItem(context, 2, 'Custom Projects', Colors.orange, '\$49,700'),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(int index, Color color, double value, String title) {
    final isHovered = index == _hoveredCategoryIndex;
    final isSelected = index == _selectedCategoryIndex;
    final isTouched = isHovered || isSelected;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 40.0 : 30.0;
    
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegendItem(BuildContext context, int index, String title, Color color, String value) {
    final theme = Theme.of(context);
    final isSelected = index == _selectedCategoryIndex;
    final isHovered = index == _hoveredCategoryIndex;
    final isTouched = isSelected || isHovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) => setState(() => _hoveredCategoryIndex = -1),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategoryIndex = isSelected ? -1 : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isTouched ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrillDownChart(BuildContext context, Map charts) {
    final theme = Theme.of(context);
    
    if (_selectedCategoryIndex == -1) {
      return PremiumCard(
        child: SizedBox(
          height: 350,
          child: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.mousePointerClick, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Select a Category', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Text('Click on the donut chart to view top products', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400)),
            ],
          ),
        ),
        ),
      );
    }

    String title;
    List<BarChartGroupData> data;
    List<String> labels;

    switch (_selectedCategoryIndex) {
      case 0: // Office Furniture
        title = 'Top Products: Office Furniture';
        labels = ['Ergo Chair', 'Standing Desk', 'Conference Table', 'Cabinet'];
        data = [_makeSimpleBar(0, 45, Colors.teal), _makeSimpleBar(1, 35, Colors.teal), _makeSimpleBar(2, 20, Colors.teal), _makeSimpleBar(3, 11.8, Colors.teal)];
        break;
      case 1: // Home Living
        title = 'Top Products: Home Living';
        labels = ['Sofa Set', 'Dining Table', 'Bed Frame', 'Bookshelf'];
        data = [_makeSimpleBar(0, 32, Colors.blue), _makeSimpleBar(1, 28, Colors.blue), _makeSimpleBar(2, 15, Colors.blue), _makeSimpleBar(3, 11.9, Colors.blue)];
        break;
      case 2: // Custom Projects
        title = 'Top Projects: Custom';
        labels = ['HQ Lobby', 'Retail Store', 'Hotel Suite', 'Cafeteria'];
        data = [_makeSimpleBar(0, 25, Colors.orange), _makeSimpleBar(1, 15, Colors.orange), _makeSimpleBar(2, 6, Colors.orange), _makeSimpleBar(3, 3.7, Colors.orange)];
        break;
      default:
        return const SizedBox.shrink();
    }

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () => setState(() => _selectedCategoryIndex = -1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem('\$${rod.toY}k\n${labels[group.x]}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(meta: meta, child: Text(labels[value.toInt()].split(' ').first, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text('\$${value.toInt()}k', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  BarChartGroupData _makeSimpleBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersList(BuildContext context, Map widgets) {
    final theme = Theme.of(context);
    final recentOrders = widgets['recent_orders'] as List<dynamic>? ?? [];

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('Recent Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: recentOrders.isEmpty 
              ? const Center(child: Text("No recent orders."))
              : ListView.separated(
                itemCount: recentOrders.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(order['order_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(order['customer'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${order['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        Text(order['status'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
