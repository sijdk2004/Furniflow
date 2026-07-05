import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/production_order_provider.dart';

class ProductionOrderViewScreen extends ConsumerStatefulWidget {
  final String orderId;
  const ProductionOrderViewScreen({super.key, required this.orderId});

  @override
  ConsumerState<ProductionOrderViewScreen> createState() => _ProductionOrderViewScreenState();
}

class _ProductionOrderViewScreenState extends ConsumerState<ProductionOrderViewScreen> {

  final List<String> _workflowSteps = ['Draft', 'Released', 'In Progress', 'Completed'];

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ref.read(productionOrderProvider.notifier).updateStatus(widget.orderId, newStatus);
      // ignore: unused_result
      ref.refresh(productionOrderByIdProvider(widget.orderId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildTimeline(String currentStatus) {
    int currentIndex = _workflowSteps.indexOf(currentStatus);
    bool isCancelled = currentStatus == 'Cancelled';

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Row(
          children: [
            Icon(LucideIcons.xCircle, color: Colors.red),
            SizedBox(width: 16),
            Text('This Production Order has been cancelled.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(_workflowSteps.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          // Divider line
          int stepIndex = index ~/ 2;
          bool isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 4,
              color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
            ),
          );
        }

        // Node
        int stepIndex = index ~/ 2;
        bool isCompleted = stepIndex < currentIndex;
        bool isCurrent = stepIndex == currentIndex;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey.withOpacity(0.2)),
                border: isCurrent ? Border.all(color: Colors.blue.shade200, width: 4) : null,
              ),
              child: isCompleted 
                ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                : (isCurrent ? const Icon(LucideIcons.loader, color: Colors.white, size: 16) : null),
            ),
            const SizedBox(height: 8),
            Text(
              _workflowSteps[stepIndex],
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted || isCurrent ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(productionOrderByIdProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Production Order Details'),
      ),
      body: orderAsync.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order: PRD-${order.id.substring(0,8).toUpperCase()}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Created on ${FormatHelper.formatDateTime24(order.createdOn)}', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    // Action Buttons based on status
                    Row(
                      children: [
                        if (order.status == 'Draft') ...[
                          OutlinedButton(
                            onPressed: () => _updateStatus('Cancelled'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Cancel Order'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _updateStatus('Released'),
                            icon: const Icon(LucideIcons.playCircle, size: 18),
                            label: const Text('Release to Production'),
                          ),
                        ] else if (order.status == 'Released') ...[
                          ElevatedButton.icon(
                            onPressed: () => _updateStatus('In Progress'),
                            icon: const Icon(LucideIcons.hammer, size: 18),
                            label: const Text('Start Work'),
                          ),
                        ] else if (order.status == 'In Progress') ...[
                          ElevatedButton.icon(
                            onPressed: () => _updateStatus('Completed'),
                            icon: const Icon(LucideIcons.checkCircle, size: 18),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            label: const Text('Mark Completed'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Timeline
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Production Timeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        _buildTimeline(order.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manufacturing Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const Divider(height: 32),
                              _buildInfoRow('Product', order.product?['product_name'] ?? order.productId),
                              _buildInfoRow('SKU', order.product?['product_code'] ?? 'N/A'),
                              _buildInfoRow('Quantity to Make', order.quantity.toString()),
                              _buildInfoRow('BOM Used', 'Version ${order.bomVersion} (ID: ${order.bomId.substring(0,8)})'),
                              if (order.salesOrderId != null)
                                _buildInfoRow('Linked Sales Order', 'SO-${order.salesOrderId!.substring(0,8)}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cost Snapshot', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const Divider(height: 32),
                              _buildCostRow('Material', order.materialCost),
                              _buildCostRow('Labor', order.laborCost),
                              _buildCostRow('Overhead', order.overheadCost),
                              const Divider(height: 24),
                              _buildCostRow('Total Estimated Cost', order.totalCost, isBold: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? null : Colors.grey.shade700)),
          Text(FormatHelper.formatCurrency(amount), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
