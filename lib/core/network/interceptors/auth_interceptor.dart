import 'dart:async';
import 'package:dio/dio.dart';
import '../../local_storage/secure_storage_service.dart';
import '../api_constants.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final void Function() _onLogout;

  Completer<bool>? _refreshTokenCompleter;

  AuthInterceptor(this._secureStorage, this._dio, {required void Function() onLogout}) : _onLogout = onLogout;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If a refresh is in progress, wait for it before proceeding.
    // Ensure we don't block the refresh request itself!
    if (_refreshTokenCompleter != null && !_refreshTokenCompleter!.isCompleted && options.path != ApiConstants.refreshEndpoint) {
      await _refreshTokenCompleter!.future;
    }

    // Inject Access Token
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers[ApiConstants.authHeader] = 'Bearer $accessToken';
    }

    // Inject Tenant and Org IDs
    final tenantId = await _secureStorage.getTenantId();
    if (tenantId != null) {
      options.headers[ApiConstants.tenantIdHeader] = tenantId;
    }

    final orgId = await _secureStorage.getOrganizationId();
    if (orgId != null) {
      options.headers[ApiConstants.orgIdHeader] = orgId;
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized globally
    if (err.response?.statusCode == 401 && err.requestOptions.path != ApiConstants.loginEndpoint && err.requestOptions.path != ApiConstants.refreshEndpoint) {
      
      final bool success;

      if (_refreshTokenCompleter == null || _refreshTokenCompleter!.isCompleted) {
        _refreshTokenCompleter = Completer<bool>();
        success = await _refreshToken();
        _refreshTokenCompleter!.complete(success);
      } else {
        success = await _refreshTokenCompleter!.future;
      }

      if (success) {
        // Retry original request
        try {
          final retryResponse = await _retry(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          if (e is DioException) {
            return super.onError(e, handler);
          }
        }
      } else {
        // Refresh failed, trigger global logout event
        _onLogout();
      }
    }
    super.onError(err, handler);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiConstants.refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final newAccessToken = await _secureStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    if (newAccessToken != null) {
      options.headers?[ApiConstants.authHeader] = 'Bearer $newAccessToken';
    }

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
