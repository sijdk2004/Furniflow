import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/providers/network_providers.dart';

class DeliveryDashboardState {
  final Map<String, dynamic>? data;
  final String timeframe;
  final bool isLoading;
  final String? error;

  DeliveryDashboardState({
    this.data,
    this.timeframe = '1M',
    this.isLoading = false,
    this.error,
  });

  DeliveryDashboardState copyWith({
    Map<String, dynamic>? data,
    String? timeframe,
    bool? isLoading,
    String? error,
  }) {
    return DeliveryDashboardState(
      data: data ?? this.data,
      timeframe: timeframe ?? this.timeframe,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DeliveryDashboardNotifier extends AutoDisposeAsyncNotifier<DeliveryDashboardState> {
  @override
  FutureOr<DeliveryDashboardState> build() async {
    return _fetchData('1M');
  }

  Future<DeliveryDashboardState> _fetchData(String timeframe) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/v1/system/delivery-dashboard/data', queryParameters: {'timeframe': timeframe});
      
      if (response.data != null && response.data['success'] == true) {
        return DeliveryDashboardState(data: Map<String, dynamic>.from(response.data['data'] as Map), timeframe: timeframe);
      } else {
        throw Exception('Failed to load delivery dashboard data');
      }
    } catch (e) {
      throw Exception('Failed to load delivery dashboard data: $e');
    }
  }

  Future<void> setTimeframe(String timeframe) async {
    state = const AsyncLoading<DeliveryDashboardState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchData(timeframe));
  }
}

final deliveryDashboardNotifierProvider = AsyncNotifierProvider.autoDispose<DeliveryDashboardNotifier, DeliveryDashboardState>(() {
  return DeliveryDashboardNotifier();
});
