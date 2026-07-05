import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/format_helper.dart';

class DeliveryTimeline extends StatelessWidget {
  final List<dynamic> histories;
  final String currentStatus;

  const DeliveryTimeline({
    super.key,
    required this.histories,
    required this.currentStatus,
  });

  static const _stages = ['Scheduled', 'Dispatched', 'In Transit', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == 'Cancelled') {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Delivery Cancelled', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final history = histories[index];
            final isLast = index == histories.length - 1;
            final date = DateTime.parse(history['timestamp']);
            
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.backgroundDark, width: 2),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history['stage'],
                            style: const TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FormatHelper.formatDateTime(date),
                            style: const TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 12,
                            ),
                          ),
                          if (history['remarks'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                history['remarks'],
                                style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
