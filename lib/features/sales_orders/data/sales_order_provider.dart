import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/sales_order_model.dart';

final salesOrderProvider =
    AsyncNotifierProvider<SalesOrderNotifier, List<SalesOrder>>(
        SalesOrderNotifier.new);

class SalesOrderNotifier extends AsyncNotifier<List<SalesOrder>> {
  late final ApiClient _apiClient;

  @override
  Future<List<SalesOrder>> build() async {
    _apiClient = ref.watch(apiClientProvider);
    return _fetchSalesOrders();
  }

  Future<List<SalesOrder>> _fetchSalesOrders() async {
    final response = await _apiClient.get('/v1/system/sales-orders');
    final data = response.data['data'] as List;
    return data.map((json) => SalesOrder.fromJson(json)).toList();
  }

  Future<void> loadSalesOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _fetchSalesOrders();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<SalesOrder> getSalesOrderById(String id) async {
    final response = await _apiClient.get('/v1/system/sales-orders/$id');
    return SalesOrder.fromJson(response.data['data']);
  }

  Future<void> updateSalesOrder(
    String id, {
    DateTime? expectedDeliveryDate,
    String? remarks,
    double discount = 0,
    required List<SalesOrderItem> items,
  }) async {
    await _apiClient.put(
      '/v1/system/sales-orders/$id',
      data: {
        'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'remarks': remarks,
        'discount': discount,
        'items': items
            .map((e) => {
                  'product_id': e.productId,
                  'quantity': e.quantity,
                  'unit_price': e.unitPrice,
                })
            .toList(),
      },
    );
    await loadSalesOrders();
  }

  Future<void> updateStatus(String id, String status) async {
    await _apiClient.patch(
      '/v1/system/sales-orders/$id/status',
      data: {'status': status},
    );
    await loadSalesOrders();
  }
}
