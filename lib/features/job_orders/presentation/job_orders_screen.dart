import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../data/job_order_providers.dart';
import '../domain/job_order_model.dart';

class JobOrdersScreen extends ConsumerStatefulWidget {
  const JobOrdersScreen({super.key});

  @override
  ConsumerState<JobOrdersScreen> createState() => _JobOrdersScreenState();
}

class _JobOrdersScreenState extends ConsumerState<JobOrdersScreen> {
  final List<String> _stages = ['Cutting', 'Sanding', 'Assembly', 'Polishing', 'Finishing'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobOrders = ref.watch(jobOrdersProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Orders Workflow', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage manufacturing stages and assignments', style: theme.textTheme.bodyMedium),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _showPrintBoardDialog(context),
                  icon: const Icon(LucideIcons.printer, size: 18),
                  label: const Text('Print Board'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),
          
          // Kanban Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _stages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stage = entry.value;
                  final columnOrders = jobOrders.where((jo) => jo.stage == stage).toList();
                  
                  return Expanded(
                    child: DragTarget<JobOrder>(
                      onAcceptWithDetails: (details) {
                        ref.read(jobOrdersProvider.notifier).updateStage(details.data.id, stage);
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovered = candidateData.isNotEmpty;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isHovered 
                              ? theme.colorScheme.primary.withOpacity(0.1) 
                              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: isHovered ? Border.all(color: theme.colorScheme.primary) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        stage,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${columnOrders.length}',
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: columnOrders.length,
                                  itemBuilder: (context, iIndex) {
                                    return _buildJobOrderCard(columnOrders[iIndex], theme)
                                        .animate()
                                        .fade(delay: (100 * iIndex).ms)
                                        .slideY(begin: 0.1);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJobOrderCard(JobOrder order, ThemeData theme) {
    Color priorityColor;
    switch (order.priority) {
      case 'High': priorityColor = Colors.red; break;
      case 'Medium': priorityColor = Colors.orange; break;
      default: priorityColor = Colors.blue; break;
    }

    final isOverdue = order.dueDate.isBefore(DateTime.now());

    final card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () => _showJobOrderDetailsDialog(context, order),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.priority,
                      style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.componentName,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                order.productionOrderId,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        order.assignedTo.split(' ').first,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 14, color: isOverdue ? Colors.red : Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d').format(order.dueDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Draggable<JobOrder>(
      data: order,
      feedback: SizedBox(width: 300, child: Opacity(opacity: 0.9, child: card)),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  void _showJobOrderDetailsDialog(BuildContext context, JobOrder order) {
    Color priorityColor;
    switch (order.priority) {
      case 'High': priorityColor = Colors.red; break;
      case 'Medium': priorityColor = Colors.orange; break;
      default: priorityColor = Colors.blue; break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Job Order: ${order.id}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(order.priority, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: priorityColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.componentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text('Production Order: ${order.productionOrderId}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('Stage', order.stage)),
                  Expanded(child: _buildDetailRow('Assigned To', order.assignedTo)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('Due Date', DateFormat('MMM d, yyyy').format(order.dueDate))),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Instructions / QA Checklist', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('- Verify wood moisture content before cutting\n- Sand to 220 grit smoothness\n- Check tolerances within 0.5mm'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (_stages.indexOf(order.stage) < _stages.length - 1)
            ElevatedButton.icon(
              onPressed: () {
                final currentIndex = _stages.indexOf(order.stage);
                final newStage = _stages[currentIndex + 1];
                ref.read(jobOrdersProvider.notifier).updateStage(order.id, newStage);
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.arrowRight, size: 16), 
              label: const Text('Advance Stage'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.check, size: 16), 
              label: const Text('Complete Order'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showPrintBoardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Job Board'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select which departments should receive the printed job board schedule:'),
              const SizedBox(height: 16),
              CheckboxListTile(title: const Text('Cutting Department'), value: true, onChanged: (v) {}),
              CheckboxListTile(title: const Text('Assembly Line'), value: true, onChanged: (v) {}),
              CheckboxListTile(title: const Text('Finishing & QA'), value: false, onChanged: (v) {}),
              const SizedBox(height: 16),
              const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: 'A4 Landscape',
                items: ['A4 Landscape', 'A3 Poster', 'Digital PDF'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.printer, size: 16), label: const Text('Print Now')),
        ],
      ),
    );
  }
}
