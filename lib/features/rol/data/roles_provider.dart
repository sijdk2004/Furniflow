import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/role_model.dart';
import '../domain/permission_model.dart';
import '../domain/audit_log_model.dart';
import '../../usr/domain/user_model.dart';

final rolesProvider = FutureProvider<List<RoleModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles');
  
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => RoleModel.fromJson(json)).toList();
  } else {
    throw Exception(response.data['error'] ?? 'Failed to load roles');
  }
});

final roleDetailsProvider = FutureProvider.family<RoleModel, String>((ref, roleId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles/$roleId');
  if (response.data['success'] == true) {
    return RoleModel.fromJson(response.data['data']);
  }
  throw Exception(response.data['error'] ?? 'Failed to load role details');
});

final allPermissionsProvider = FutureProvider<List<PermissionModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles/permissions');
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => PermissionModel.fromJson(json)).toList();
  }
  throw Exception(response.data['error'] ?? 'Failed to load permissions');
});

final rolePermissionsProvider = FutureProvider.family<List<PermissionModel>, String>((ref, roleId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles/$roleId/permissions');
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => PermissionModel.fromJson(json)).toList();
  }
  throw Exception(response.data['error'] ?? 'Failed to load role permissions');
});

final roleUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, roleId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles/$roleId/users');
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }
  throw Exception(response.data['error'] ?? 'Failed to load role users');
});

final roleAuditLogsProvider = FutureProvider.family<List<AuditLogModel>, String>((ref, roleId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/v1/system/roles/$roleId/audit-history');
  if (response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => AuditLogModel.fromJson(json)).toList();
  }
  throw Exception(response.data['error'] ?? 'Failed to load audit logs');
});

class RoleRepository {
  final dynamic apiClient;
  RoleRepository(this.apiClient);

  Future<void> createRole({required String roleCode, required String roleName}) async {
    final response = await apiClient.post('/v1/system/roles', data: {
      'role_code': roleCode,
      'role_name': roleName,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to create role');
    }
  }

  Future<void> updateRole({required String roleId, required String roleCode, required String roleName}) async {
    final response = await apiClient.put('/v1/system/roles/$roleId', data: {
      'role_code': roleCode,
      'role_name': roleName,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to update role');
    }
  }

  Future<void> deleteRole(String roleId) async {
    final response = await apiClient.delete('/v1/system/roles/$roleId');
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to delete role');
    }
  }

  Future<void> updateRolePermissions(String roleId, List<String> permissionIds) async {
    await apiClient.put('/v1/system/roles/$roleId/permissions', data: {'permission_ids': permissionIds});
  }

  Future<void> updateRoleUsers(String roleId, List<String> userIds) async {
    await apiClient.put('/v1/system/roles/$roleId/users', data: {'user_ids': userIds});
  }
}

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(apiClientProvider));
});
