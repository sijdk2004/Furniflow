import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local_storage/secure_storage_service.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../api_client.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Interceptor Providers
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  
  // A dedicated internal Dio for the refresh request to avoid interceptor loops
  final refreshDio = Dio();
  
  return AuthInterceptor(secureStorage, refreshDio, onLogout: () {
    // Global Logout Event Trigger
    Future.microtask(() {
      ref.read(authProvider.notifier).logout();
    });
  });
});

final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  return ErrorInterceptor();
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  // Instantiate Dio here to prevent shared mutation across rebuilds
  final dio = Dio();
  final authInterceptor = ref.watch(authInterceptorProvider);
  final errorInterceptor = ref.watch(errorInterceptorProvider);
  return ApiClient(dio, authInterceptor, errorInterceptor);
});
