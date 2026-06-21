import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'premium_dashboard_widgets.dart';

class RevenueTrendNode {
  final String label;
  final double value;
  final List<RevenueTrendNode> children;

  RevenueTrendNode({
    required this.label,
    required this.value,
    this.children = const [],
  });

  factory RevenueTrendNode.fromJson(Map<String, dynamic> json) {
    return RevenueTrendNode(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => RevenueTrendNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DrillDownBarChart extends StatefulWidget {
  final List<dynamic> rawData;

  const DrillDownBarChart({super.key, required this.rawData});

  @override
  State<DrillDownBarChart> createState() => _DrillDownBarChartState();
}

class _DrillDownBarChartState extends State<DrillDownBarChart> {
  List<RevenueTrendNode> _rootData = [];
  List<RevenueTrendNode> _currentData = [];
  List<List<RevenueTrendNode>> _history = [];
  List<String> _breadcrumbs = ['All Years'];

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  @override
  void didUpdateWidget(DrillDownBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rawData != oldWidget.rawData) {
      _parseData();
    }
  }

  void _parseData() {
    _rootData = widget.rawData
        .map((e) => RevenueTrendNode.fromJson(e as Map<String, dynamic>))
        .toList();
    _currentData = List.from(_rootData);
    _history.clear();
    _breadcrumbs = ['All Years'];
  }

  void _drillDown(RevenueTrendNode node) {
    if (node.children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No further details available for ${node.label}.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return; 
    }
    setState(() {
      _history.add(List.from(_currentData)); // Deep copy the list reference just to be safe
      _breadcrumbs.add(node.label);
      _currentData = node.children;
    });
  }

  void _drillUp() {
    if (_history.isEmpty) return;
    setState(() {
      _currentData = _history.removeLast();
      _breadcrumbs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate max value for Y-axis scaling
    double maxY = 0;
    for (var node in _currentData) {
      if (node.value > maxY) maxY = node.value;
    }
    // Add 20% padding to maxY
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100; // default if no data

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hierarchical Revenue Trend',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (int i = 0; i < _breadcrumbs.length; i++) ...[
                        Text(
                          _breadcrumbs[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: i == _breadcrumbs.length - 1
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            fontWeight: i == _breadcrumbs.length - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (i < _breadcrumbs.length - 1)
                          const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                      ]
                    ],
                  ),
                ],
              ),
              if (_history.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _drillUp,
                  icon: const Icon(LucideIcons.arrowUpCircle, size: 16),
                  label: const Text('Drill Up'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    elevation: 0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_currentData[groupIndex].label}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '\$${(rod.toY / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_currentData[groupIndex].children.isNotEmpty)
                            const TextSpan(
                              text: '\n(Click to Drill Down)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      return;
                    }
                    if (event is FlTapUpEvent || event is FlTapDownEvent || event.runtimeType.toString() == 'FlPointerDownEvent') {
                      int index = barTouchResponse.spot!.touchedBarGroupIndex;
                      if (index >= 0 && index < _currentData.length) {
                        _drillDown(_currentData[index]);
                      }
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\$${(value / 1000).toInt()}k',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= _currentData.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _currentData[index].label,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _currentData.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
