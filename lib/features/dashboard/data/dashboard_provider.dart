import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient);
});

// Using a custom class to hold both the data and the filter options
class DashboardState {
  final Map<String, dynamic>? data;
  final String timeframe;

  DashboardState({this.data, this.timeframe = 'YTD'});

  DashboardState copyWith({Map<String, dynamic>? data, String? timeframe}) {
    return DashboardState(
      data: data ?? this.data,
      timeframe: timeframe ?? this.timeframe,
    );
  }
}

class DashboardNotifier extends AsyncNotifier<DashboardState> {
  late DashboardRepository _repository;

  @override
  FutureOr<DashboardState> build() async {
    _repository = ref.watch(dashboardRepositoryProvider);
    return _fetchDashboardData('YTD');
  }

  Future<DashboardState> _fetchDashboardData(String timeframe) async {
    final response = await _repository.getDashboardData(timeframe);
    return DashboardState(data: response, timeframe: timeframe);
  }

  Future<void> setTimeframe(String timeframe) async {
    // Keep old data while loading
    final oldData = state.value?.data;
    state = AsyncValue.data(DashboardState(data: oldData, timeframe: timeframe));
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDashboardData(timeframe));
  }
}

final dashboardNotifierProvider = AsyncNotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> getDashboardData(String timeframe) async {
    final response = await _apiClient.get(
      '/v1/system/dashboard/data',
      queryParameters: {'timeframe': timeframe},
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
