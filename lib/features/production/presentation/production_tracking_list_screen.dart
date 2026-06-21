import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../data/production_tracking_provider.dart';

class ProductionTrackingListScreen extends ConsumerStatefulWidget {
  const ProductionTrackingListScreen({super.key});

  @override
  ConsumerState<ProductionTrackingListScreen> createState() => _ProductionTrackingListScreenState();
}

class _ProductionTrackingListScreenState extends ConsumerState<ProductionTrackingListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(productionBoardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: boardState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tracking data available',
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
                          DataColumn(label: Text('Order No', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Product', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Customer', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Stage', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Team', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Progress', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold))),
                        ],
                        rows: items.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.orderNumber, style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(Text(item.productName, style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(Text(item.customerName ?? 'N/A', style: const TextStyle(color: AppColors.textPrimaryDark))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStageColor(item.currentStage).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.currentStage,
                                    style: TextStyle(color: _getStageColor(item.currentStage), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(Text(item.assignedTeam ?? 'Unassigned', style: const TextStyle(color: AppColors.textSecondaryDark))),
                              DataCell(
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: item.completionPercentage / 100,
                                        backgroundColor: AppColors.backgroundDark,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${item.completionPercentage}%', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                                  ],
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye, color: AppColors.primary, size: 20),
                                  onPressed: () => context.go('/tracking/view/${item.trackingId}'),
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

  Widget _buildHeader() {
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
                'Production Tracking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View list of all production tracking orders',
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('/tracking/board'),
            icon: const Icon(Icons.dashboard, size: 18),
            label: const Text('View Board'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: AppColors.textPrimaryDark,
              side: const BorderSide(color: AppColors.borderDark),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'Cutting': return Colors.orange;
      case 'Assembly': return Colors.blue;
      case 'Finishing': return Colors.purple;
      case 'Quality Control': return Colors.amber;
      case 'Completed': return Colors.green;
      default: return AppColors.textSecondaryDark;
    }
  }
}
