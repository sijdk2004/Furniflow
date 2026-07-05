import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../features/auth/presentation/rbac_provider.dart';
import '../data/production_tracking_provider.dart';
import 'widgets/production_timeline.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';

class ProductionTrackingScreen extends ConsumerWidget {
  final String trackingId;

  const ProductionTrackingScreen({super.key, required this.trackingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(productionTrackingDetailProvider(trackingId));
    final rbac = ref.watch(rbacProvider);
    final canUpdate = rbac.hasPermission('MFG.TRK.UPDATE');

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Production Tracking Detail', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: trackingAsync.when(
        data: (tracking) {
          final isCompleted = tracking.currentStage == 'Ready For Delivery' || tracking.completionPercentage == 100;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrackingHeader(tracking),
                const SizedBox(height: 24),
                if (!isCompleted && canUpdate) ...[
                  _buildActions(context, ref, tracking),
                  const SizedBox(height: 24),
                ],
                if (!canUpdate)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('View only — you do not have permission to update stages.', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                const Text('Stage Timeline', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ProductionTimelineWidget(histories: tracking.histories),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildTrackingHeader(ProductionTrackingModel tracking) {
    Color stageColor = AppColors.primary;
    if (tracking.currentStage == 'On Hold') stageColor = Colors.amber;
    if (tracking.currentStage == 'Ready For Delivery') stageColor = Colors.green;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Current Stage: ${tracking.currentStage}', style: TextStyle(color: stageColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              if (tracking.currentStage == 'On Hold')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: const Text('ON HOLD', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: tracking.completionPercentage / 100,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                  minHeight: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text('${tracking.completionPercentage}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (tracking.assignedTeam != null)
            Text('Assigned Team: ${tracking.assignedTeam}', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, ProductionTrackingModel tracking) {
    final currentHistory = tracking.histories.isNotEmpty ? tracking.histories.first : null;
    final isStarted = currentHistory?.stageStartedAt != null;
    final isOnHold = tracking.currentStage == 'On Hold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (!isStarted && !isOnHold)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Stage'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    final repo = ref.read(productionTrackingRepositoryProvider);
                    await repo.startStage(tracking.id);
                    ref.refresh(productionTrackingDetailProvider(tracking.id));
                  },
                ),
              ),
            if (isStarted && !isOnHold)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Complete & Move Next'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => _showNextStageDialog(context, ref, tracking),
                ),
              ),
            if (isOnHold)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Resume Production'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => _resumeProduction(context, ref, tracking),
                ),
              ),
          ],
        ),
        if (!isOnHold) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.pause_circle_outline, color: Colors.amber),
            label: const Text('Put On Hold', style: TextStyle(color: Colors.amber)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.amber),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _showOnHoldDialog(context, ref, tracking),
          ),
        ],
      ],
    );
  }

  void _resumeProduction(BuildContext context, WidgetRef ref, ProductionTrackingModel tracking) async {
    final stages = [
      "Raw Material Ready", "Cutting", "Carpentry", "Assembly", "Sanding",
      "Sealer", "Painting", "Polishing", "Drying", "Quality Inspection",
      "Packing", "Ready For Delivery"
    ];
    // Resume to the last known production stage from history
    String resumeStage = "Raw Material Ready";
    for (final h in tracking.histories) {
      if (stages.contains(h.stage)) {
        resumeStage = h.stage;
        break;
      }
    }

    final repo = ref.read(productionTrackingRepositoryProvider);
    await repo.updateStage(tracking.id, resumeStage,
        team: tracking.assignedTeam,
        remarks: 'Resumed from On Hold');
    ref.refresh(productionTrackingDetailProvider(tracking.id));
    ref.refresh(productionBoardProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Production resumed successfully'), backgroundColor: Colors.green),
      );
    }
  }

  void _showOnHoldDialog(BuildContext context, WidgetRef ref, ProductionTrackingModel tracking) {
    final holdReasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Put On Hold', style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pausing production will retain stage history.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: holdReasonController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Hold Reason *',
                labelStyle: const TextStyle(color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              if (holdReasonController.text.trim().isEmpty) return;
              final repo = ref.read(productionTrackingRepositoryProvider);
              await repo.updateStage(
                tracking.id,
                'On Hold',
                remarks: holdReasonController.text,
                delayReason: holdReasonController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              ref.refresh(productionTrackingDetailProvider(tracking.id));
              ref.refresh(productionBoardProvider);
            },
            child: const Text('Confirm Hold', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showNextStageDialog(BuildContext context, WidgetRef ref, ProductionTrackingModel tracking) {
    final stages = [
      "Raw Material Ready", "Cutting", "Carpentry", "Assembly", "Sanding", 
      "Sealer", "Painting", "Polishing", "Drying", "Quality Inspection", 
      "Packing", "Ready For Delivery"
    ];
    
    int currentIndex = stages.indexOf(tracking.currentStage);
    String nextStage = currentIndex + 1 < stages.length ? stages[currentIndex + 1] : stages.last;

    final teamController = TextEditingController(text: tracking.assignedTeam);
    final remarksController = TextEditingController();
    final delayController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Advance to Next Stage', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current: ${tracking.currentStage}', style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                SearchableDropdown<String>(
                  label: 'Next Stage',
                  items: stages.sublist(currentIndex),
                  itemAsString: (s) => s,
                  selectedItem: nextStage,
                  onChanged: (val) {
                    if (val != null) nextStage = val;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: teamController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Assigned Team (Optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarksController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Remarks (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: delayController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Delay Reason (If Any)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(productionTrackingRepositoryProvider);
                await repo.updateStage(
                  tracking.id,
                  nextStage,
                  team: teamController.text.isNotEmpty ? teamController.text : null,
                  remarks: remarksController.text.isNotEmpty ? remarksController.text : null,
                  delayReason: delayController.text.isNotEmpty ? delayController.text : null,
                );
                if (context.mounted) Navigator.pop(context);
                ref.refresh(productionTrackingDetailProvider(tracking.id));
                ref.refresh(productionBoardProvider);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
