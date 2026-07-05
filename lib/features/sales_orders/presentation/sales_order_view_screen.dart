import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/sales_order_provider.dart';

class SalesOrderViewScreen extends ConsumerStatefulWidget {
  final String orderId;

  const SalesOrderViewScreen({super.key, required this.orderId});

  @override
  ConsumerState<SalesOrderViewScreen> createState() => _SalesOrderViewScreenState();
}

class _SalesOrderViewScreenState extends ConsumerState<SalesOrderViewScreen> {

  final List<String> _statusWorkflow = [
    'Draft',
    'Confirmed',
    'In Production',
    'Ready For Delivery',
    'Delivered'
  ];

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ref.read(salesOrderProvider.notifier).updateStatus(widget.orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Widget _buildTimeline(String currentStatus) {
    if (currentStatus == 'Cancelled') {
      return const Center(
        child: Text(
          'ORDER CANCELLED',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );
    }

    int currentIndex = _statusWorkflow.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      children: List.generate(_statusWorkflow.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 4,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final stepName = _statusWorkflow[stepIndex];
        final isCompleted = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
                border: isCurrent ? Border.all(color: Colors.green.shade800, width: 3) : null,
              ),
              child: Icon(
                isCompleted ? LucideIcons.check : LucideIcons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stepName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNextAction(String currentStatus) {
    String? nextStatus;
    switch (currentStatus) {
      case 'Draft':
        nextStatus = 'Confirmed';
        break;
      case 'Confirmed':
        nextStatus = 'In Production';
        break;
      case 'In Production':
        nextStatus = 'Ready For Delivery';
        break;
      case 'Ready For Delivery':
        nextStatus = 'Delivered';
        break;
    }

    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (currentStatus == 'Draft' || currentStatus == 'Confirmed')
          TextButton(
            onPressed: () => _updateStatus('Cancelled'),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _updateStatus(nextStatus!),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Mark as $nextStatus'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(salesOrderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Sales Order: ${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.printer),
            onPressed: () {},
          ),
        ],
      ),
      body: asyncOrders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == widget.orderId, orElse: () => throw Exception('Not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Status Tracking', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        _buildTimeline(order.status),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildNextAction(order.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Text(order.customer?['name'] ?? 'Unknown', style: theme.textTheme.bodyLarge),
                              Text(order.customer?['email'] ?? '', style: theme.textTheme.bodyMedium),
                              Text(order.customer?['phone'] ?? '', style: theme.textTheme.bodyMedium),
                              
                              const SizedBox(height: 32),
                              
                              Text('Order Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildInfoRow('Order Date:', FormatHelper.formatDate(order.orderDate)),
                              if (order.quotationId != null)
                                _buildInfoRow('Quotation Ref:', order.quotationId!),
                              _buildInfoRow('Expected Delivery:', order.expectedDeliveryDate != null ? FormatHelper.formatDate(order.expectedDeliveryDate!) : 'Not Set'),
                              if (order.remarks != null && order.remarks!.isNotEmpty)
                                _buildInfoRow('Remarks:', order.remarks!),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Line Items & Totals
                    Expanded(
                      flex: 3,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Line Items', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final item = order.items[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(item.product?['name'] ?? 'Product ${item.productId}'),
                                    subtitle: Text('${item.quantity} x ${FormatHelper.formatCurrency(item.unitPrice)}'),
                                    trailing: Text(FormatHelper.formatCurrency(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                              const Divider(thickness: 2),
                              const SizedBox(height: 16),
                              _buildTotalRow('Subtotal', order.subtotal),
                              _buildTotalRow('Discount', order.discount, color: Colors.red),
                              _buildTotalRow('Tax', order.tax),
                              const Divider(),
                              _buildTotalRow('Total Amount', order.totalAmount, isBold: true),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(
            FormatHelper.formatCurrency(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
