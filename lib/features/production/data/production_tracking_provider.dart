import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';

class ProductionTrackingModel {
  final String id;
  final String productionOrderId;
  final String currentStage;
  final String? assignedTeam;
  final String? assignedEmployeeId;
  final int completionPercentage;
  final DateTime? stageStartDate;
  final DateTime? stageEndDate;
  final List<ProductionStageHistoryModel> histories;

  ProductionTrackingModel({
    required this.id,
    required this.productionOrderId,
    required this.currentStage,
    this.assignedTeam,
    this.assignedEmployeeId,
    required this.completionPercentage,
    this.stageStartDate,
    this.stageEndDate,
    this.histories = const [],
  });

  factory ProductionTrackingModel.fromJson(Map<String, dynamic> json) {
    return ProductionTrackingModel(
      id: json['id'],
      productionOrderId: json['production_order_id'],
      currentStage: json['current_stage'],
      assignedTeam: json['assigned_team'],
      assignedEmployeeId: json['assigned_employee_id'],
      completionPercentage: json['completion_percentage'] ?? 0,
      stageStartDate: json['stage_start_date'] != null ? DateTime.parse(json['stage_start_date']) : null,
      stageEndDate: json['stage_end_date'] != null ? DateTime.parse(json['stage_end_date']) : null,
      histories: (json['histories'] as List?)?.map((e) => ProductionStageHistoryModel.fromJson(e)).toList() ?? [],
    );
  }
}

class ProductionStageHistoryModel {
  final String id;
  final String stage;
  final DateTime stageEnteredAt;
  final DateTime? stageStartedAt;
  final DateTime? stageCompletedAt;
  final int? durationMinutes;
  final String? delayReason;
  final String? remarks;

  ProductionStageHistoryModel({
    required this.id,
    required this.stage,
    required this.stageEnteredAt,
    this.stageStartedAt,
    this.stageCompletedAt,
    this.durationMinutes,
    this.delayReason,
    this.remarks,
  });

  factory ProductionStageHistoryModel.fromJson(Map<String, dynamic> json) {
    return ProductionStageHistoryModel(
      id: json['id'],
      stage: json['stage'],
      stageEnteredAt: DateTime.parse(json['stage_entered_at']),
      stageStartedAt: json['stage_started_at'] != null ? DateTime.parse(json['stage_started_at']) : null,
      stageCompletedAt: json['stage_completed_at'] != null ? DateTime.parse(json['stage_completed_at']) : null,
      durationMinutes: json['duration_minutes'],
      delayReason: json['delay_reason'],
      remarks: json['remarks'],
    );
  }
}

class ProductionBoardItem {
  final String trackingId;
  final String productionOrderId;
  final String orderNumber;
  final String? salesOrderId;
  final String productId;
  final String productName;
  final String? customerName;
  final String currentStage;
  final String status;
  final DateTime? plannedEndDate;
  final int completionPercentage;
  final String? assignedTeam;

  ProductionBoardItem({
    required this.trackingId,
    required this.productionOrderId,
    required this.orderNumber,
    this.salesOrderId,
    required this.productId,
    required this.productName,
    this.customerName,
    required this.currentStage,
    required this.status,
    this.plannedEndDate,
    required this.completionPercentage,
    this.assignedTeam,
  });

  factory ProductionBoardItem.fromJson(Map<String, dynamic> json) {
    return ProductionBoardItem(
      trackingId: json['tracking_id'],
      productionOrderId: json['production_order_id'],
      orderNumber: json['order_number'],
      salesOrderId: json['sales_order_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      customerName: json['customer_name'],
      currentStage: json['current_stage'],
      status: json['status'],
      plannedEndDate: json['planned_end_date'] != null ? DateTime.parse(json['planned_end_date']) : null,
      completionPercentage: json['completion_percentage'] ?? 0,
      assignedTeam: json['assigned_team'],
    );
  }
}

class ProductionTrackingRepository {
  final ApiClient _apiClient;

  ProductionTrackingRepository(this._apiClient);

  Future<List<ProductionBoardItem>> getBoardItems() async {
    final response = await _apiClient.get('/v1/system/manufacturing/production-tracking/board');
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((x) => ProductionBoardItem.fromJson(x)).toList();
  }

  Future<ProductionTrackingModel> ensureTrackingExists(String orderId) async {
    final response = await _apiClient.post('/v1/system/manufacturing/production-tracking/ensure/$orderId');
    return ProductionTrackingModel.fromJson(response.data['data']);
  }

  Future<ProductionTrackingModel> getTrackingById(String id) async {
    final response = await _apiClient.get('/v1/system/manufacturing/production-tracking/$id');
    return ProductionTrackingModel.fromJson(response.data['data']);
  }

  Future<void> startStage(String id) async {
    await _apiClient.put('/v1/system/manufacturing/production-tracking/$id/start');
  }

  Future<void> updateStage(String id, String nextStage, {String? team, String? remarks, String? delayReason}) async {
    await _apiClient.put('/v1/system/manufacturing/production-tracking/$id/stage', data: {
      'next_stage': nextStage,
      'assigned_team': team,
      'remarks': remarks,
      'delay_reason': delayReason,
    });
  }
}

final productionTrackingRepositoryProvider = Provider<ProductionTrackingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductionTrackingRepository(apiClient);
});

final productionBoardProvider = FutureProvider.autoDispose<List<ProductionBoardItem>>((ref) async {
  final repo = ref.watch(productionTrackingRepositoryProvider);
  return repo.getBoardItems();
});

final productionTrackingDetailProvider = FutureProvider.family.autoDispose<ProductionTrackingModel, String>((ref, id) async {
  final repo = ref.watch(productionTrackingRepositoryProvider);
  return repo.getTrackingById(id);
});
