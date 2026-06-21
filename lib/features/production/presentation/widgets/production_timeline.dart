import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../data/production_tracking_provider.dart';

class ProductionTimelineWidget extends StatelessWidget {
  final List<ProductionStageHistoryModel> histories;

  const ProductionTimelineWidget({super.key, required this.histories});

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) {
      return const Text('No history available.', style: TextStyle(color: Colors.white54));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        final isFirst = index == 0;
        final isLast = index == histories.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: isFirst ? Colors.transparent : AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: history.stageCompletedAt != null ? AppColors.primary : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isLast ? Colors.transparent : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(history.stage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            if (history.durationMinutes != null)
                              Text('${history.durationMinutes} mins', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Entered: ${DateFormat('MMM dd, yyyy HH:mm').format(history.stageEnteredAt)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        if (history.stageStartedAt != null)
                          Text('Started: ${DateFormat('MMM dd, yyyy HH:mm').format(history.stageStartedAt!)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        if (history.stageCompletedAt != null)
                          Text('Completed: ${DateFormat('MMM dd, yyyy HH:mm').format(history.stageCompletedAt!)}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                        if (history.remarks != null) ...[
                          const SizedBox(height: 8),
                          Text('Remarks: ${history.remarks}', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                        ],
                        if (history.delayReason != null) ...[
                          const SizedBox(height: 8),
                          Text('Delay Reason: ${history.delayReason}', style: const TextStyle(color: Colors.redAccent)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
