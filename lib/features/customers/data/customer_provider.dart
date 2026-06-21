import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/customer_model.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CustomerRepository(apiClient);
});

class CustomerRepository {
  final dynamic apiClient;
  CustomerRepository(this.apiClient);

  Future<List<CustomerModel>> getCustomers() async {
    final response = await apiClient.get('/v1/system/customers');
    final data = response.data['data'] as List;
    return data.map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> getCustomer(String id) async {
    final response = await apiClient.get('/v1/system/customers/$id');
    return CustomerModel.fromJson(response.data['data']);
  }

  Future<void> createCustomer(Map<String, dynamic> payload) async {
    await apiClient.post('/v1/system/customers', data: payload);
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> payload) async {
    await apiClient.put('/v1/system/customers/$id', data: payload);
  }

  Future<void> deleteCustomer(String id) async {
    await apiClient.delete('/v1/system/customers/$id');
  }
}

final customersProvider = FutureProvider.autoDispose<List<CustomerModel>>((ref) {
  return ref.watch(customerRepositoryProvider).getCustomers();
});
