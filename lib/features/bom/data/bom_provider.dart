import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/bom_model.dart';

final bomProvider = AsyncNotifierProvider<BomNotifier, List<Bom>>(() {
  return BomNotifier();
});

class BomNotifier extends AsyncNotifier<List<Bom>> {
  @override
  FutureOr<List<Bom>> build() async {
    return _fetchBoms();
  }

  Future<List<Bom>> _fetchBoms() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/v1/system/manufacturing/boms');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((json) => Bom.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load BOMs');
    }
  }

  Future<void> loadBoms() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBoms());
  }

  Future<void> createBom(Map<String, dynamic> data) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/v1/system/manufacturing/boms', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadBoms(); // Refresh list
      } else {
        throw Exception('Failed to create BOM');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.patch('/v1/system/manufacturing/boms/$id/status', data: {'status': status});
      if (response.statusCode == 200) {
        await loadBoms();
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
