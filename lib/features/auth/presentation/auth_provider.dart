import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/local_storage/secure_storage_service.dart';
import '../../../core/network/providers/network_providers.dart';
import '../data/auth_repository.dart';
import 'rbac_provider.dart';
import '../../dashboard/data/dashboard_provider.dart';
import '../../dashboard/data/sales_dashboard_provider.dart';
import '../../dashboard/data/manufacturing_dashboard_provider.dart';
import '../../dashboard/data/delivery_dashboard_provider.dart';

enum AuthStateStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStateStatus status;
  final String? errorMessage;
  AuthState({required this.status, this.errorMessage});
}

class AuthNotifier extends Notifier<AuthState> {
  late SecureStorageService _secureStorage;
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _secureStorage = ref.watch(secureStorageServiceProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _checkInitialState();
    return AuthState(status: AuthStateStatus.initial);
  }

  Future<void> _checkInitialState() async {
    final token = await _secureStorage.getAccessToken();
    // Fetch cached permissions to persist menus across refresh
    final permissions = await _secureStorage.getPermissions();
    if (permissions.isNotEmpty) {
      ref.read(rbacProvider.notifier).setPermissions(permissions);
    }
    
    if (token != null && token.isNotEmpty) {
      state = AuthState(status: AuthStateStatus.authenticated);
    } else {
      state = AuthState(status: AuthStateStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password, String tenantId) async {
    state = AuthState(status: AuthStateStatus.loading);
    try {
      final response = await _authRepository.login(username, password, tenantId);
      
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _secureStorage.saveTenantAndOrg(tenantId: tenantId, orgId: 'default');
      
      // Update RBAC state and save to storage
      ref.read(rbacProvider.notifier).setPermissions(response.permissions);
      await _secureStorage.savePermissions(response.permissions);
      
      state = AuthState(status: AuthStateStatus.authenticated);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Login failed. Please check your credentials.';
      state = AuthState(status: AuthStateStatus.error, errorMessage: msg.toString());
    } catch (e) {
      state = AuthState(status: AuthStateStatus.error, errorMessage: 'An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    if (state.status == AuthStateStatus.unauthenticated) return;
    state = AuthState(status: AuthStateStatus.unauthenticated);
    
    await _secureStorage.clearAll();
    ref.read(rbacProvider.notifier).clear();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
