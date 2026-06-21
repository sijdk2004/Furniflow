import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manufacturing Command Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Real-time production floor visualization and tracking', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showLiveFloorViewDialog(context),
                  icon: const Icon(LucideIcons.activity, size: 18),
                  label: const Text('Live Floor View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
            const SizedBox(height: 32),

            // KPIs
            Row(
              children: [
                Expanded(child: _buildKpiCard('Active Orders', '45', '+12', true, LucideIcons.factory, Colors.blue, theme, isDark).animate().fade(delay: 100.ms)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Delayed Orders', '2', '-3', true, LucideIcons.alertTriangle, Colors.red, theme, isDark).animate().fade(delay: 200.ms)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Work Centers Active', '8/10', '80%', true, LucideIcons.cpu, Colors.purple, theme, isDark).animate().fade(delay: 300.ms)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Machine Utilization', '88%', '+2%', true, LucideIcons.zap, Colors.orange, theme, isDark).animate().fade(delay: 400.ms)),
              ],
            ),
            const SizedBox(height: 32),

            // Production Flow Visualization
            Text('Live Production Stages', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildProductionFlow(theme, isDark),

            const SizedBox(height: 32),

            // Gantt Chart
            Text('Production Timeline (Next 7 Days)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGanttChart(theme, isDark).animate().fade(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String trend, bool isPositive, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: isPositive ? Colors.green : Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('vs last week', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductionFlow(ThemeData theme, bool isDark) {
    final stages = [
      {'name': 'Cutting', 'count': 12, 'color': Colors.blue},
      {'name': 'Assembly', 'count': 18, 'color': Colors.orange},
      {'name': 'Sanding', 'count': 5, 'color': Colors.amber},
      {'name': 'Polishing', 'count': 8, 'color': Colors.purple},
      {'name': 'Finishing', 'count': 2, 'color': Colors.teal},
      {'name': 'Ready', 'count': 24, 'color': Colors.green},
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stages.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            );
          }
          final stageIndex = index ~/ 2;
          final stage = stages[stageIndex];
          return Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (stage['color'] as Color).withOpacity(0.1),
                  border: Border.all(color: stage['color'] as Color, width: 2),
                  boxShadow: [
                    BoxShadow(color: (stage['color'] as Color).withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${stage['count']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: stage['color'] as Color),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(stage['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ).animate().scale(delay: (100 * stageIndex).ms);
        }),
      ),
    );
  }

  Widget _buildGanttChart(ThemeData theme, bool isDark) {
    final orders = [
      {'name': 'ORD-1042 (Exec Desks)', 'start': 0.0, 'duration': 2.5, 'color': Colors.blue},
      {'name': 'ORD-1043 (Dining Chairs)', 'start': 1.0, 'duration': 4.0, 'color': Colors.orange},
      {'name': 'ORD-1044 (Bookshelves)', 'start': 2.5, 'duration': 2.0, 'color': Colors.purple},
      {'name': 'ORD-1045 (Cabinets)', 'start': 4.0, 'duration': 3.0, 'color': Colors.teal},
      {'name': 'ORD-1046 (Conference Table)', 'start': 0.5, 'duration': 5.0, 'color': Colors.indigo},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header (Days)
          Row(
            children: [
              const SizedBox(width: 200),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => Text('Day ${i + 1}', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
          const SizedBox(height: 16),
          // Rows
          ...orders.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(order['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final startPixel = width * ((order['start'] as double) / 7.0);
                        final durationPixel = width * ((order['duration'] as double) / 7.0);
                        return Stack(
                          children: [
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              left: startPixel,
                              width: durationPixel,
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: order['color'] as Color,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(color: (order['color'] as Color).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                                  ]
                                ),
                                child: Center(
                                  child: Text(
                                    '${order['duration']} Days',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showLiveFloorViewDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 900,
          height: 600,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.activity, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Live Floor View', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Colors.red, size: 8),
                            SizedBox(width: 6),
                            Text('LIVE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 1.seconds),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.2) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Grid background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GridPainter(isDark: isDark),
                        ),
                      ),
                      // Work Centers
                      _buildWorkCenter(context, 'Cutting Station A', 100, 50, true),
                      _buildWorkCenter(context, 'Cutting Station B', 100, 250, true),
                      _buildWorkCenter(context, 'Assembly Line 1', 350, 50, true),
                      _buildWorkCenter(context, 'Assembly Line 2', 350, 250, false), // Offline
                      _buildWorkCenter(context, 'Sanding & Polishing', 600, 50, true),
                      _buildWorkCenter(context, 'Finishing & QA', 600, 250, true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkCenter(BuildContext context, String name, double x, double y, bool isOnline) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isOnline ? Colors.green : Colors.red;

    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: 180,
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ).animate(onPlay: isOnline ? (c) => c.repeat(reverse: true) : null).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds),
              ],
            ),
            const Spacer(),
            Text(isOnline ? 'Operating Normally' : 'Maintenance Required', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: isOnline ? 0.85 : 0.0,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;
  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
