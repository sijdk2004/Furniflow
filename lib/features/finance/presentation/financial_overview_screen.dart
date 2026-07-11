import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  State<FinancialOverviewScreen> createState() => _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  String _selectedDateRange = 'This Month';
  final List<String> _dateRanges = ['This Month', 'Last Month', 'Quarter', 'Financial Year', 'Custom Date'];
  String _plView = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildHealthScore(context),
            const SizedBox(height: 32),
            _buildExecutiveKPIs(context, isDesktop),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRevenueVsExpenseChart(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildProfitAndLoss(context)),
                ],
              )
            else
              Column(
                children: [
                  _buildRevenueVsExpenseChart(context),
                  const SizedBox(height: 24),
                  _buildProfitAndLoss(context),
                ],
              ),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildProfitabilityAnalysis(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildTopCustomers(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildReceivablesAging(context)),
                ],
              )
            else
              Column(
                children: [
                  _buildProfitabilityAnalysis(context),
                  const SizedBox(height: 24),
                  _buildTopCustomers(context),
                  const SizedBox(height: 24),
                  _buildReceivablesAging(context),
                ],
              ),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildCashFlowSnapshot(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildInventoryImpact(context)),
                ],
              )
            else
              Column(
                children: [
                  _buildCashFlowSnapshot(context),
                  const SizedBox(height: 24),
                  _buildInventoryImpact(context),
                ],
              ),
            const SizedBox(height: 32),
             if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildQuotationPipeline(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildOrderBookAnalysis(context)),
                ],
              )
            else
              Column(
                children: [
                  _buildQuotationPipeline(context),
                  const SizedBox(height: 24),
                  _buildOrderBookAnalysis(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finance Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Business Health Center', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildGlobalFilters(),
            _buildExportActions(context),
          ],
        ),
      ],
    ).animate().fade().slideY(begin: -0.2);
  }

  Widget _buildGlobalFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.calendar, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDateRange,
              items: _dateRanges.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDateRange = val);
              },
              icon: const Icon(LucideIcons.chevronDown, size: 18),
            ),
          ),
          const VerticalDivider(width: 32, indent: 8, endIndent: 8),
          const Icon(LucideIcons.building, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'All Branches',
              items: const [
                DropdownMenuItem(value: 'All Branches', child: Text('All Branches', style: TextStyle(fontWeight: FontWeight.w600))),
                DropdownMenuItem(value: 'HQ', child: Text('Headquarters', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
              onChanged: (val) {},
              icon: const Icon(LucideIcons.chevronDown, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildActionButton(context, LucideIcons.fileText, 'PDF', Colors.red.shade600),
        _buildActionButton(context, LucideIcons.fileSpreadsheet, 'Excel', Colors.green.shade600),
        _buildActionButton(context, LucideIcons.share2, 'Share', Colors.blue.shade600),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(BuildContext context) {
    return PremiumCard(
      child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(value: 87, color: Colors.green, radius: 12, showTitle: false),
                            PieChartSectionData(value: 13, color: Colors.grey.shade200, radius: 12, showTitle: false),
                          ],
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('87', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.green)),
                          const Text('Excellent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Business Health Score', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const MiniProgress(label: 'Profitability', value: 0.9, color: Colors.green),
                      const SizedBox(height: 4),
                      const MiniProgress(label: 'Cash Flow', value: 0.85, color: Colors.green),
                      const SizedBox(height: 4),
                      const MiniProgress(label: 'Receivables', value: 0.7, color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 100.ms).slideX(begin: -0.1);
  }

  Widget _buildInsightPill(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildMiniProgress(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: value, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutiveKPIs(BuildContext context, bool isDesktop) {
    final kpis = [
      GradientKpiCard(title: 'Total Revenue', value: '₹ 3.48 Cr', subtitle: '+12.4% vs last month', icon: LucideIcons.trendingUp, gradientColors: [Colors.teal.shade400, Colors.teal.shade700]),
      GradientKpiCard(title: 'Gross Profit', value: '₹ 1.06 Cr', subtitle: '+8.2%', icon: LucideIcons.dollarSign, gradientColors: [Colors.blue.shade400, Colors.blue.shade700]),
      GradientKpiCard(title: 'Net Profit', value: '₹ 72.5 Lakhs', subtitle: '+6.8%', icon: LucideIcons.pieChart, gradientColors: [Colors.purple.shade400, Colors.purple.shade700]),
      GradientKpiCard(title: 'Outstanding Receivables', value: '₹ 48 Lakhs', subtitle: '-3.2%', icon: LucideIcons.alertCircle, gradientColors: [Colors.orange.shade400, Colors.orange.shade700], isNegativeGood: true),
      GradientKpiCard(title: 'Cash Position', value: '₹ 62 Lakhs', subtitle: '+10.5%', icon: LucideIcons.wallet, gradientColors: [Colors.green.shade400, Colors.green.shade700]),
      GradientKpiCard(title: 'Inventory Value', value: '₹ 1.92 Cr', subtitle: '+4.1%', icon: LucideIcons.boxes, gradientColors: [Colors.indigo.shade400, Colors.indigo.shade700]),
      GradientKpiCard(title: 'Pending Quotations', value: '₹ 85 Lakhs', subtitle: '', icon: LucideIcons.fileText, gradientColors: [Colors.cyan.shade400, Colors.cyan.shade700]),
      GradientKpiCard(title: 'Pending Orders', value: '₹ 1.37 Cr', subtitle: '', icon: LucideIcons.shoppingCart, gradientColors: [Colors.pink.shade400, Colors.pink.shade700]),
    ];

    if (isDesktop) {
      return Column(
        children: [
          Row(children: [Expanded(child: kpis[0]), const SizedBox(width: 16), Expanded(child: kpis[1]), const SizedBox(width: 16), Expanded(child: kpis[2]), const SizedBox(width: 16), Expanded(child: kpis[3])]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: kpis[4]), const SizedBox(width: 16), Expanded(child: kpis[5]), const SizedBox(width: 16), Expanded(child: kpis[6]), const SizedBox(width: 16), Expanded(child: kpis[7])]),
        ],
      );
    } else {
      return Wrap(spacing: 16, runSpacing: 16, children: kpis.map((k) => SizedBox(width: double.infinity, child: k)).toList());
    }
  }

  Widget _buildGradientKpiCard(BuildContext context, String title, String value, String subtitle, IconData icon, List<Color> gradientColors, {bool isNegativeGood = false}) {
    bool isPositive = subtitle.startsWith('+');
    bool isTrendingGood = isNegativeGood ? !isPositive : isPositive;
    Color trendColor = isTrendingGood ? Colors.greenAccent : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: gradientColors[1].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14))),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder(
             tween: Tween<double>(begin: 0, end: 1),
             duration: const Duration(seconds: 1),
             builder: (context, val, child) {
               return Opacity(
                 opacity: val,
                 child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
               );
             }
          ),
          const SizedBox(height: 12),
          if (subtitle.isNotEmpty)
            Row(
              children: [
                Icon(isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: trendColor, size: 16),
                const SizedBox(width: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            )
          else
             const SizedBox(height: 16),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildProfitAndLoss(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text('Profit & Loss', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Monthly', 'Quarterly', 'Yearly'].map((t) => 
                    GestureDetector(
                      onTap: () => setState(() => _plView = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _plView == t ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _plView == t ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                        ),
                        child: Text(t, style: TextStyle(fontSize: 12, fontWeight: _plView == t ? FontWeight.bold : FontWeight.normal)),
                      ),
                    )
                  ).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPLRow('Revenue', '₹ 3,48,00,000', isBold: true, color: Colors.teal),
          _buildPLRow('Less: Cost of Goods Sold', '₹ 2,42,00,000', isIndented: true),
          const Divider(height: 24),
          _buildPLRow('Gross Profit', '₹ 1,06,00,000', isBold: true, color: Colors.blue),
          _buildPLRow('Less: Operating Expenses', '₹ 22,00,000', isIndented: true),
          const Divider(height: 24),
          _buildPLRow('Operating Profit', '₹ 84,00,000', isBold: true, color: Colors.orange),
          _buildPLRow('Less: Taxes', '₹ 11,50,000', isIndented: true),
          const Divider(height: 24, thickness: 2),
          _buildPLRow('Net Profit', '₹ 72,50,000', isBold: true, color: Colors.purple, fontSize: 18),
        ],
      ),
    );
  }

  Widget _buildPLRow(String label, String value, {bool isBold = false, bool isIndented = false, Color? color, double? fontSize}) {
    return Padding(
      padding: EdgeInsets.only(left: isIndented ? 16.0 : 0, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? (isIndented ? Colors.grey.shade700 : Colors.black87), fontSize: fontSize)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color ?? Colors.black87, fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildRevenueVsExpenseChart(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue vs Expenses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (val, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    if (val.toInt() >= 0 && val.toInt() < months.length) {
                       return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(months[val.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)));
                    }
                    return const Text('');
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}L', style: const TextStyle(color: Colors.grey, fontSize: 12)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 150), FlSpot(1, 180), FlSpot(2, 200), FlSpot(3, 220), FlSpot(4, 250), FlSpot(5, 290), FlSpot(6, 310), FlSpot(7, 348)],
                    isCurved: true, color: Colors.teal, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.teal.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 100), FlSpot(1, 120), FlSpot(2, 130), FlSpot(3, 140), FlSpot(4, 160), FlSpot(5, 180), FlSpot(6, 200), FlSpot(7, 210)],
                    isCurved: true, color: Colors.redAccent, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 70), FlSpot(3, 80), FlSpot(4, 90), FlSpot(5, 110), FlSpot(6, 110), FlSpot(7, 138)],
                    isCurved: true, color: Colors.purple, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false), dashArray: [5, 5]
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Revenue', Colors.teal), const SizedBox(width: 24),
              _buildLegend('Expenses', Colors.redAccent), const SizedBox(width: 24),
              _buildLegend('Profit', Colors.purple),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfitabilityAnalysis(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Performing Products', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildProductProfitRow('Classic Dining Table', '₹ 38 L', '₹ 12 L', 0.31),
          _buildProductProfitRow('Ergo Office Chair', '₹ 25 L', '₹ 9 L', 0.36),
          _buildProductProfitRow('Luxury Sofa Set', '₹ 42 L', '₹ 11 L', 0.26),
          _buildProductProfitRow('Oak Bookshelf', '₹ 18 L', '₹ 7 L', 0.38),
          _buildProductProfitRow('Minimalist Bed', '₹ 22 L', '₹ 6.5 L', 0.29),
        ],
      ),
    );
  }

  Widget _buildProductProfitRow(String name, String rev, String profit, double margin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(rev, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: margin, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple), minHeight: 8),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 60, child: Text('${(margin * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purple))),
              SizedBox(width: 60, child: Text(profit, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Customers by Revenue', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildCustomerRow('GreenSpace Interiors', '₹ 24 L', '₹ 3 L', '18%', 1),
          _buildCustomerRow('Metro Furnishings', '₹ 19 L', '₹ 0 L', '14%', 2),
          _buildCustomerRow('Apex Corporate', '₹ 15 L', '₹ 5 L', '11%', 3),
          _buildCustomerRow('Luxe Living', '₹ 12 L', '₹ 1 L', '9%', 4),
          _buildCustomerRow('Urban Spaces', '₹ 8 L', '₹ 2 L', '6%', 5),
        ],
      ),
    );
  }

  Widget _buildCustomerRow(String name, String rev, String out, String cont, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber.withOpacity(0.2) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: rank <= 3 ? Colors.amber.shade800 : Colors.grey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Outstanding: $out', style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rev, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(cont, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReceivablesAging(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receivables Aging', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(value: 40, color: Colors.green.shade400, title: '0-30', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: 25, color: Colors.blue.shade400, title: '31-60', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: 20, color: Colors.orange.shade400, title: '61-90', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: 15, color: Colors.red.shade400, title: '90+', radius: 35, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹ 48 L', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegend('0-30 Days', Colors.green.shade400),
              _buildLegend('31-60 Days', Colors.blue.shade400),
              _buildLegend('61-90 Days', Colors.orange.shade400),
              _buildLegend('90+ Days', Colors.red.shade400),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCashFlowSnapshot(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash Flow Snapshot', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                    final titles = ['Inflow', 'Outflow', 'Net Flow'];
                    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(titles[val.toInt()], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));
                  })),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 105, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 85, color: Colors.redAccent, width: 40, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 20, color: Colors.blue, width: 40, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryImpact(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inventory Financial Impact', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInventoryBar('Raw Material Value', '₹ 85 L', 0.44, Colors.indigo),
          const SizedBox(height: 16),
          _buildInventoryBar('Finished Goods Value', '₹ 75 L', 0.39, Colors.teal),
          const SizedBox(height: 16),
          _buildInventoryBar('Slow Moving Inventory', '₹ 22 L', 0.11, Colors.orange),
          const SizedBox(height: 16),
          _buildInventoryBar('Dead Stock Value', '₹ 10 L', 0.05, Colors.red),
        ],
      ),
    );
  }

  Widget _buildInventoryBar(String label, String value, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 12),
        ),
      ],
    );
  }

  Widget _buildQuotationPipeline(BuildContext context) {
     return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quotation Pipeline Value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildPipelineStep('Sent', '₹ 1.2 Cr', Colors.blue, 1.0),
          _buildPipelineStep('Viewed', '₹ 85 L', Colors.cyan, 0.7),
          _buildPipelineStep('Negotiating', '₹ 45 L', Colors.orange, 0.4),
          _buildPipelineStep('Approved', '₹ 25 L', Colors.green, 0.2),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text('Total Potential', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               Text('₹ 2.75 Cr', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Theme.of(context).colorScheme.primary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPipelineStep(String label, String value, Color color, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 60, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildOrderBookAnalysis(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Book Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildOrderBookStat('Orders Received', '142', LucideIcons.inbox, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildOrderBookStat('Orders Completed', '108', LucideIcons.checkCircle, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildOrderBookStat('Pending Value', '₹ 1.37 Cr', LucideIcons.hourglass, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildOrderBookStat('Fulfillment %', '76%', LucideIcons.activity, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

}
