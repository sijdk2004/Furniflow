import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:furniflow/core/network/interceptors/auth_interceptor.dart';
import 'package:furniflow/core/local_storage/secure_storage_service.dart';
import 'package:furniflow/core/network/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockSecureStorage extends SecureStorageService {
  MockSecureStorage() : super(const FlutterSecureStorage());
  
  bool shouldFailRefresh = false;
  int refreshCallCount = 0;

  @override
  Future<String?> getAccessToken() async => 'mock_token';
  
  @override
  Future<String?> getTenantId() async => 'mock_tenant';
  
  @override
  Future<String?> getOrganizationId() async => 'mock_org';

  @override
  Future<String?> getRefreshToken() async => 'mock_refresh';

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}

  @override
  Future<void> clearAll() async {}
}

class MockDio extends DioForNative {
  final MockSecureStorage storage;
  MockDio(this.storage);

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (path == ApiConstants.refreshEndpoint) {
      storage.refreshCallCount++;
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 50));
      if (storage.shouldFailRefresh) {
        throw DioException(requestOptions: RequestOptions(path: path));
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {'access_token': 'new_token', 'refresh_token': 'new_refresh'},
      ) as Response<T>;
    }
    throw UnimplementedError();
  }
}

class MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool isResolved = false;
  bool isNextCalled = false;

  @override
  void resolve(Response response) {
    isResolved = true;
  }

  @override
  void next(DioException err) {
    isNextCalled = true;
  }
}

void main() {
  late AuthInterceptor interceptor;
  late MockSecureStorage mockStorage;
  late MockDio mockDio;
  bool isLogoutCalled = false;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockDio = MockDio(mockStorage);
    isLogoutCalled = false;
    interceptor = AuthInterceptor(mockStorage, mockDio, onLogout: () {
      isLogoutCalled = true;
    });
  });

  test('onRequest injects headers correctly', () async {
    final options = RequestOptions(path: '/test');
    final handler = RequestInterceptorHandler();
    
    interceptor.onRequest(options, handler);
    // Let event loop process the async method
    await Future.delayed(Duration.zero);

    expect(options.headers[ApiConstants.authHeader], 'Bearer mock_token');
    expect(options.headers[ApiConstants.tenantIdHeader], 'mock_tenant');
    expect(options.headers[ApiConstants.orgIdHeader], 'mock_org');
  });

  test('onError with 401 triggers refresh and queues subsequent requests', () async {
    final options1 = RequestOptions(path: '/test1');
    final options2 = RequestOptions(path: '/test2');
    
    final err1 = DioException(
      requestOptions: options1,
      response: Response(requestOptions: options1, statusCode: 401),
    );
    final err2 = DioException(
      requestOptions: options2,
      response: Response(requestOptions: options2, statusCode: 401),
    );

    final handler1 = MockErrorInterceptorHandler();
    final handler2 = MockErrorInterceptorHandler();

    // Trigger both errors simultaneously
    interceptor.onError(err1, handler1);
    interceptor.onError(err2, handler2);

    await Future.delayed(const Duration(milliseconds: 100));

    // Refresh should only be called ONCE
    expect(mockStorage.refreshCallCount, 1);
  });

  test('onError with 401 triggers logout on refresh failure', () async {
    mockStorage.shouldFailRefresh = true;
    final options = RequestOptions(path: '/test');
    
    final err = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );
    
    final handler = MockErrorInterceptorHandler();

    interceptor.onError(err, handler);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(isLogoutCalled, true);
    expect(handler.isNextCalled, true);
  });
}
