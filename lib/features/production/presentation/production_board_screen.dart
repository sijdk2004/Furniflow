import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../data/production_tracking_provider.dart';

// Dynamic stages will be fetched from provider

class ProductionBoardScreen extends ConsumerWidget {
  const ProductionBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(productionBoardProvider);
    final stagesAsync = ref.watch(productionStagesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Production Board', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              ref.refresh(productionBoardProvider);
              ref.refresh(productionStagesProvider);
            },
          ),
        ],
      ),
      body: stagesAsync.when(
        data: (stages) {
          return boardAsync.when(
            data: (items) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double minColumnWidth = 280.0;
                  final double totalNeededWidth = stages.length * (minColumnWidth + 16);
                  final bool isScrollable = totalNeededWidth > constraints.maxWidth;

                  Widget row = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stages.map((stage) {
                      final stageItems = items.where((i) => i.currentStage == stage).toList();
                      if (isScrollable) {
                        return _buildKanbanColumn(context, ref, stage, stageItems, stages, width: minColumnWidth);
                      } else {
                        return Expanded(
                          child: _buildKanbanColumn(context, ref, stage, stageItems, stages),
                        );
                      }
                    }).toList(),
                  );

                  return isScrollable
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(16),
                          child: row,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: row,
                        );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error loading board: $error', style: const TextStyle(color: Colors.redAccent))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading stages: $error', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, WidgetRef ref, String stage, List<ProductionBoardItem> items, List<String> stages, {double? width}) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stage,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Drop Target Area
          Expanded(
            child: DragTarget<ProductionBoardItem>(
              onWillAcceptWithDetails: (details) {
                final item = details.data;
                final currentIndex = stages.indexOf(item.currentStage);
                final targetIndex = stages.indexOf(stage);
                // Allow only moving sequentially forward by exactly 1 step
                return targetIndex == currentIndex + 1;
              },
              onAcceptWithDetails: (details) async {
                final item = details.data;
                try {
                  await ref.read(productionTrackingRepositoryProvider).updateStage(item.trackingId, stage);
                  ref.invalidate(productionBoardProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update stage: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: candidateData.isNotEmpty ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(6),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildDraggableCard(context, ref, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(BuildContext context, WidgetRef ref, ProductionBoardItem item) {
    return Draggable<ProductionBoardItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 200, // 220 width - 20 padding roughly
          child: _buildCardContent(context, ref, item, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(context, ref, item),
      ),
      child: _buildCardContent(context, ref, item),
    );
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref, ProductionBoardItem item, {bool isDragging = false}) {
    final isBlocked = item.isOnHold;
    return Card(
      color: isBlocked ? Colors.red.withOpacity(0.1) : AppColors.surfaceDark.withOpacity(0.8),
      margin: const EdgeInsets.only(bottom: 4),
      elevation: isDragging ? 8 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isBlocked ? Colors.redAccent : (isDragging ? AppColors.primary : Colors.white.withOpacity(0.05)),
          width: isBlocked || isDragging ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/tracking/view/${item.trackingId}'),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: ID and Team
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.orderNumber,
                          style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            if (isBlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2)),
                                child: const Text('ON HOLD', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            if (item.assignedTeam != null && item.assignedTeam!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text(item.assignedTeam!, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (item.completionPercentage < 100)
                    InkWell(
                      onTap: () => _showToggleHoldDialog(context, ref, item),
                      child: Icon(
                        isBlocked ? Icons.play_arrow : Icons.pause,
                        color: isBlocked ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Main Title: Product Name
              Text(
                item.productName,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Customer info (if any)
              if ((item.customerName ?? '').isNotEmpty)
                Text(
                  item.customerName!,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              // Bottom row: Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: item.completionPercentage / 100,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.completionPercentage}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToggleHoldDialog(BuildContext context, WidgetRef ref, ProductionBoardItem item) {
    final reasonController = TextEditingController();
    final isCurrentlyHold = item.isOnHold;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(isCurrentlyHold ? 'Resume Production' : 'Put On Hold', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCurrentlyHold ? 'Are you sure you want to resume this order?' : 'Why are you putting this order on hold?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Reason / Remarks',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(productionTrackingRepositoryProvider).toggleHold(
                      item.trackingId,
                      !isCurrentlyHold,
                      reason: reasonController.text,
                    );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(productionBoardProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isCurrentlyHold ? Colors.green : Colors.orange),
            child: Text(isCurrentlyHold ? 'Resume' : 'Hold', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
