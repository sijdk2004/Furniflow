import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';

class ProductionOrder {
  final String id;
  final String? salesOrderId;
  final String productId;
  final String bomId;
  final int bomVersion;
  final int quantity;
  final String status;
  final DateTime createdOn;
  final double materialCost;
  final double laborCost;
  final double overheadCost;
  final double totalCost;
  final Map<String, dynamic>? product;

  ProductionOrder({
    required this.id,
    this.salesOrderId,
    required this.productId,
    required this.bomId,
    required this.bomVersion,
    required this.quantity,
    required this.status,
    required this.createdOn,
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.totalCost,
    this.product,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      id: json['id'] ?? '',
      salesOrderId: json['sales_order_id'],
      productId: json['product_id'] ?? '',
      bomId: json['bom_id'] ?? '',
      bomVersion: json['bom_version'] ?? 1,
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? 'Draft',
      createdOn: DateTime.parse(json['created_on']),
      materialCost: double.parse(json['material_cost']?.toString() ?? '0'),
      laborCost: double.parse(json['labor_cost']?.toString() ?? '0'),
      overheadCost: double.parse(json['overhead_cost']?.toString() ?? '0'),
      totalCost: double.parse(json['total_cost']?.toString() ?? '0'),
      product: json['product'],
    );
  }
}

class ProductionOrderNotifier extends AsyncNotifier<List<ProductionOrder>> {
  late ApiClient _apiClient;

  @override
  Future<List<ProductionOrder>> build() async {
    _apiClient = ref.watch(apiClientProvider);
    return _fetchOrders();
  }

  Future<List<ProductionOrder>> _fetchOrders() async {
    final response = await _apiClient.get('/v1/system/manufacturing/production-orders');
    final data = response.data['data'] as List;
    return data.map((json) => ProductionOrder.fromJson(json)).toList();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _fetchOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createOrder(Map<String, dynamic> payload) async {
    await _apiClient.post('/v1/system/manufacturing/production-orders', data: payload);
    await loadOrders();
  }

  Future<void> updateStatus(String id, String status) async {
    await _apiClient.patch('/v1/system/manufacturing/production-orders/$id/status', data: {'status': status});
    await loadOrders();
  }
}

final productionOrderProvider = AsyncNotifierProvider<ProductionOrderNotifier, List<ProductionOrder>>(() {
  return ProductionOrderNotifier();
});

final productionOrderByIdProvider = FutureProvider.family<ProductionOrder, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/manufacturing/production-orders/$id');
  return ProductionOrder.fromJson(response.data['data']);
});

final completedProductionOrdersProvider = FutureProvider<List<ProductionOrder>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/manufacturing/production-orders?status=Completed');
  final data = response.data['data'] as List;
  return data.map((json) => ProductionOrder.fromJson(json)).toList();
});
