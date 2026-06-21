import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String username, String password, String tenantId);
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<AuthResponseModel> login(String username, String password, String tenantId) async {
    final response = await _dio.post(
      'http://127.0.0.1:3000/v1/auth/login',
      data: {
        'username': username,
        'password': password,
        'tenant_id': tenantId,
      },
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['Accept'] = 'application/json';
  return AuthRepositoryImpl(dio);
});
