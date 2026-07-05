import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/theme/colors.dart';
import '../data/delivery_provider.dart';
import 'widgets/delivery_timeline.dart';

class DeliveryViewScreen extends ConsumerStatefulWidget {
  final String id;
  const DeliveryViewScreen({super.key, required this.id});

  @override
  ConsumerState<DeliveryViewScreen> createState() => _DeliveryViewScreenState();
}

class _DeliveryViewScreenState extends ConsumerState<DeliveryViewScreen> {
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _updateStatus(String newStatus, bool requireAck) async {
    bool customerAck = false;
    if (requireAck) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Customer Acknowledgement', style: TextStyle(color: AppColors.textPrimaryDark)),
          content: const Text('Did the customer acknowledge receipt of this delivery?', style: TextStyle(color: AppColors.textSecondaryDark)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed == null || !confirmed) return;
      customerAck = true;
    }

    try {
      final repo = ref.read(deliveryRepositoryProvider);
      await repo.updateDeliveryStatus(widget.id, {
        'status': newStatus,
        'remarks': _remarksController.text.isNotEmpty ? _remarksController.text : null,
        'customer_acknowledgement': customerAck,
      });

      if (mounted) {
        _remarksController.clear();
        ref.invalidate(deliveryDetailProvider(widget.id));
        ref.invalidate(deliveriesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delivery marked as $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(deliveryDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Delivery Details', style: TextStyle(color: AppColors.textPrimaryDark)),
        backgroundColor: AppColors.surfaceDark,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (delivery) {
          final isDeliveredOrCancelled = delivery['status'] == 'Delivered' || delivery['status'] == 'Cancelled';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildInfoCard(delivery),
                      const SizedBox(height: 24),
                      if (!isDeliveredOrCancelled) _buildActionCard(delivery['status']),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Card(
                    color: AppColors.surfaceDark,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DeliveryTimeline(
                        histories: delivery['histories'] ?? [],
                        currentStatus: delivery['status'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> delivery) {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery: ${delivery['delivery_number']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    delivery['status'],
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.borderDark, height: 32),
            _buildDetailRow('Production Order', delivery['order_number']),
            _buildDetailRow('Customer', delivery['customer_name']),
            _buildDetailRow('Product', delivery['product']),
            _buildDetailRow('Expected Delivery', FormatHelper.formatDate(DateTime.parse(delivery['expected_delivery_date']))),
            if (delivery['delivery_date'] != null)
              _buildDetailRow('Actual Delivery', FormatHelper.formatDate(DateTime.parse(delivery['delivery_date']))),
            const Divider(color: AppColors.borderDark, height: 32),
            _buildDetailRow('Assigned Vehicle', delivery['assigned_vehicle'] ?? 'Not Assigned'),
            _buildDetailRow('Assigned Driver', delivery['assigned_driver'] ?? 'Not Assigned'),
            _buildDetailRow('Notes', delivery['delivery_notes'] ?? 'None'),
            _buildDetailRow('Ack Received', delivery['customer_acknowledgement'] ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondaryDark)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String currentStatus) {
    String? nextActionLabel;
    String? nextStatus;
    bool requireAck = false;

    switch (currentStatus) {
      case 'Scheduled':
        nextActionLabel = 'Dispatch Delivery';
        nextStatus = 'Dispatched';
        break;
      case 'Dispatched':
        nextActionLabel = 'Mark In Transit';
        nextStatus = 'In Transit';
        break;
      case 'In Transit':
        nextActionLabel = 'Mark Delivered';
        nextStatus = 'Delivered';
        requireAck = true;
        break;
    }

    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (nextActionLabel != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(nextStatus!, requireAck),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(nextActionLabel, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                if (currentStatus == 'Scheduled') ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus('Cancelled', false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel Delivery', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
