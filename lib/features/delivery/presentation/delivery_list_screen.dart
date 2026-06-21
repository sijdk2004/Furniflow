import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../data/delivery_provider.dart';

class DeliveryListScreen extends ConsumerStatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  ConsumerState<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends ConsumerState<DeliveryListScreen> {
  @override
  Widget build(BuildContext context) {
    final deliveriesState = ref.watch(deliveriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: deliveriesState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No deliveries found',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.backgroundDark),
                        columns: const [
                          DataColumn(label: Text('Delivery No', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('PO No', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Customer', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Expected Date', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                        ],
                        rows: items.map((item) {
                          final expectedDate = DateTime.parse(item['expected_delivery_date']);
                          return DataRow(
                            cells: [
                              DataCell(Text(item['delivery_number'], style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(Text(item['order_number'], style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(Text(item['customer_name'] ?? 'N/A', style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(Text(DateFormat('MMM dd, yyyy').format(expectedDate), style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status']).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['status'],
                                    style: TextStyle(color: _getStatusColor(item['status']), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye, color: AppColors.primary, size: 20),
                                  onPressed: () => context.go('/delivery/view/${item['id']}'),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View and manage all deliveries',
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('/delivery/create'),
            icon: const Icon(Icons.add),
            label: const Text('Schedule Delivery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue;
      case 'Dispatched':
        return Colors.orange;
      case 'In Transit':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondaryDark;
    }
  }
}
