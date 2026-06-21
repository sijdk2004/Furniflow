import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../usr/domain/user_model.dart';

class SettingsRepository {
  final dynamic apiClient;
  SettingsRepository(this.apiClient);

  Future<UserModel> getProfile() async {
    final response = await apiClient.get('/v1/auth/profile');
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to load profile');
  }

  Future<void> updateProfile({
    required String firstName,
    String? lastName,
    required String email,
    String? mobile,
    String? designation,
    String? department,
  }) async {
    final response = await apiClient.put('/v1/auth/profile', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'designation': designation,
      'department': department,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to update profile');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.post('/v1/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to change password');
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient);
});

final profileProvider = FutureProvider<UserModel>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getProfile();
});
