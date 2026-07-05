import 'package:dio/dio.dart';
import '../config/env_config.dart';
// Removed network_exceptions
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio, AuthInterceptor authInterceptor, ErrorInterceptor errorInterceptor) {
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: EnvConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: EnvConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
      // LogInterceptor(requestBody: true, responseBody: true), // Temporarily disabled to prevent DWDS crash
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  Never _throwNetworkException(DioException e) {
    if (e.error is Exception) {
      throw e.error as Exception;
    }

    String message = 'Unknown error occurred';
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      message = data['error'] ?? data['message'] ?? e.message ?? 'Server error ${e.response?.statusCode}';
    } else if (e.response?.data is String) {
      message = e.response!.data as String;
    } else if (e.message != null) {
      message = e.message!;
    }
    throw Exception(message);
  }
}
