import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/providers/network_providers.dart';

class ManufacturingDashboardState {
  final Map<String, dynamic>? data;
  final String timeframe;
  final bool isLoading;
  final String? error;

  ManufacturingDashboardState({
    this.data,
    this.timeframe = 'YTD',
    this.isLoading = false,
    this.error,
  });

  ManufacturingDashboardState copyWith({
    Map<String, dynamic>? data,
    String? timeframe,
    bool? isLoading,
    String? error,
  }) {
    return ManufacturingDashboardState(
      data: data ?? this.data,
      timeframe: timeframe ?? this.timeframe,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ManufacturingDashboardNotifier extends AutoDisposeAsyncNotifier<ManufacturingDashboardState> {
  @override
  FutureOr<ManufacturingDashboardState> build() async {
    return _fetchData('YTD');
  }

  Future<ManufacturingDashboardState> _fetchData(String timeframe) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/v1/system/manufacturing-dashboard/data', queryParameters: {'timeframe': timeframe});
      
      if (response.data != null && response.data['success'] == true) {
        return ManufacturingDashboardState(data: Map<String, dynamic>.from(response.data['data'] as Map), timeframe: timeframe);
      } else {
        throw Exception('Failed to load manufacturing dashboard data');
      }
    } catch (e) {
      throw Exception('Failed to load manufacturing dashboard data: $e');
    }
  }

  Future<void> setTimeframe(String timeframe) async {
    state = const AsyncLoading<ManufacturingDashboardState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchData(timeframe));
  }
}

final manufacturingDashboardNotifierProvider = AsyncNotifierProvider.autoDispose<ManufacturingDashboardNotifier, ManufacturingDashboardState>(() {
  return ManufacturingDashboardNotifier();
});
