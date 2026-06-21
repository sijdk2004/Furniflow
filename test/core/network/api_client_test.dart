import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:furniflow/core/network/api_client.dart';
import 'package:furniflow/core/network/exceptions/network_exceptions.dart';
import 'package:furniflow/core/network/interceptors/auth_interceptor.dart';
import 'package:furniflow/core/network/interceptors/error_interceptor.dart';
import 'package:furniflow/core/local_storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockDio extends DioForNative {
  bool shouldFail = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (shouldFail) {
      // Simulate ErrorInterceptor throwing a custom NetworkException wrapped in DioException
      final customError = ServerException('Simulated Server Error');
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: customError,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'status': 'ok'},
    ) as Response<T>;
  }
}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    final authInterceptor = AuthInterceptor(
      SecureStorageService(const FlutterSecureStorage()), 
      mockDio, 
      onLogout: () {}
    );
    apiClient = ApiClient(mockDio, authInterceptor, ErrorInterceptor());
  });

  test('ApiClient unwraps DioException and throws NetworkException', () async {
    mockDio.shouldFail = true;

    try {
      await apiClient.get('/test');
      fail('Expected exception was not thrown');
    } catch (e) {
      expect(e, isA<ServerException>());
      expect((e as ServerException).message, 'Simulated Server Error');
      expect(e.statusCode, 500);
    }
  });

  test('ApiClient returns response on success', () async {
    mockDio.shouldFail = false;
    final response = await apiClient.get('/test');
    expect(response.statusCode, 200);
    expect(response.data['status'], 'ok');
  });
}
