import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/user_model.dart';

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/users');
  
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'];
    return data.map((json) => UserModel.fromJson(json)).toList();
  } else {
    throw Exception(response.data['error'] ?? 'Failed to load users');
  }
});

class UserRepository {
  final dynamic apiClient;
  UserRepository(this.apiClient);

  Future<void> createUser(Map<String, dynamic> data) async {
    await apiClient.post('/v1/system/users', data: data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await apiClient.put('/v1/system/users/$id', data: data);
  }

  Future<void> deleteUser(String id) async {
    await apiClient.delete('/v1/system/users/$id');
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

final userDetailsProvider = FutureProvider.family<UserModel, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/users/$id');
  if (response.data['success'] == true) {
    return UserModel.fromJson(response.data['data']);
  }
  throw Exception(response.data['error'] ?? 'Failed to load user details');
});
