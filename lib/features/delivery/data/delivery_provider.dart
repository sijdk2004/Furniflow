import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DeliveryRepository(apiClient);
});

final deliveriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveries();
});

final deliveryDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveryByID(id);
});

class DeliveryRepository {
  final ApiClient _apiClient;

  DeliveryRepository(this._apiClient);

  Future<List<dynamic>> getDeliveries() async {
    final response = await _apiClient.get('/v1/system/delivery');
    if (response.statusCode == 200) {
      final data = response.data;
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load deliveries');
    }
  }

  Future<Map<String, dynamic>> getDeliveryByID(String id) async {
    final response = await _apiClient.get('/v1/system/delivery/$id');
    if (response.statusCode == 200) {
      final data = response.data;
      return data['data'];
    } else {
      throw Exception('Failed to load delivery details');
    }
  }

  Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/v1/system/delivery',
      data: payload,
    );
    if (response.statusCode == 201) {
      final data = response.data;
      return data['data'];
    } else {
      throw Exception('Failed to create delivery');
    }
  }

  Future<void> updateDeliveryStatus(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      '/v1/system/delivery/$id/status',
      data: payload,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update delivery status');
    }
  }
}
