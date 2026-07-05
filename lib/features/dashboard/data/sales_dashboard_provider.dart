import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';

final salesDashboardRepositoryProvider = Provider<SalesDashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalesDashboardRepository(apiClient);
});

class SalesDashboardState {
  final Map<String, dynamic>? data;
  final String timeframe;
  final String? customerId;
  final String? productId;
  final String? status;

  SalesDashboardState({
    this.data, 
    this.timeframe = 'YTD',
    this.customerId,
    this.productId,
    this.status,
  });

  SalesDashboardState copyWith({
    Map<String, dynamic>? data, 
    String? timeframe,
    String? customerId,
    String? productId,
    String? status,
  }) {
    return SalesDashboardState(
      data: data ?? this.data,
      timeframe: timeframe ?? this.timeframe,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
    );
  }
}

class SalesDashboardNotifier extends AutoDisposeAsyncNotifier<SalesDashboardState> {
  late SalesDashboardRepository _repository;

  @override
  FutureOr<SalesDashboardState> build() async {
    _repository = ref.watch(salesDashboardRepositoryProvider);
    return _fetchSalesDashboardData(state.value?.timeframe ?? 'YTD');
  }

  Future<SalesDashboardState> _fetchSalesDashboardData(String timeframe, {String? customerId, String? productId, String? status}) async {
    final response = await _repository.getSalesDashboardData(
      timeframe: timeframe,
      customerId: customerId,
      productId: productId,
      status: status,
    );
    return SalesDashboardState(
      data: response, 
      timeframe: timeframe,
      customerId: customerId,
      productId: productId,
      status: status,
    );
  }

  Future<void> setTimeframe(String timeframe) async {
    final currentState = state.value;
    state = AsyncValue.data(currentState?.copyWith(timeframe: timeframe) ?? SalesDashboardState(timeframe: timeframe));
    
    state = const AsyncLoading<SalesDashboardState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchSalesDashboardData(
      timeframe,
      customerId: currentState?.customerId,
      productId: currentState?.productId,
      status: currentState?.status,
    ));
  }

  Future<void> updateFilters({String? customerId, String? productId, String? status}) async {
    final currentState = state.value;
    final timeframe = currentState?.timeframe ?? 'YTD';
    state = AsyncValue.data(currentState?.copyWith(
      customerId: customerId,
      productId: productId,
      status: status,
    ) ?? SalesDashboardState(timeframe: timeframe, customerId: customerId, productId: productId, status: status));

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSalesDashboardData(
      timeframe,
      customerId: customerId,
      productId: productId,
      status: status,
    ));
  }
}

final salesDashboardNotifierProvider = AsyncNotifierProvider.autoDispose<SalesDashboardNotifier, SalesDashboardState>(() {
  return SalesDashboardNotifier();
});

class SalesDashboardRepository {
  final ApiClient _apiClient;

  SalesDashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> getSalesDashboardData({
    required String timeframe,
    String? customerId,
    String? productId,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{'timeframe': timeframe};
    if (customerId != null) queryParameters['customer_id'] = customerId;
    if (productId != null) queryParameters['product_id'] = productId;
    if (status != null) queryParameters['status'] = status;

    final response = await _apiClient.get(
      '/v1/system/sales-dashboard/data',
      queryParameters: queryParameters,
    );
    if (response.data != null && response.data['success'] == true && response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data'] as Map);
    }
    return {};
  }
}
