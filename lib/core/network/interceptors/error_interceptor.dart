import 'package:dio/dio.dart';
import '../exceptions/network_exceptions.dart';
import '../models/api_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        String message = 'Unexpected error occurred';

        if (err.response?.data != null) {
          try {
            final apiError = ApiError.fromJson(err.response?.data);
            message = apiError.message;
          } catch (_) {
            message = err.response?.data.toString() ?? message;
          }
        }

        switch (statusCode) {
          case 401:
            // AuthInterceptor handles retry; if it reaches here, refresh failed.
            throw UnauthorizedException(message);
          case 403:
            throw ForbiddenException(message);
          case 404:
            throw NotFoundException(message);
          case 500:
          case 502:
          case 503:
          case 504:
            throw ServerException(message);
          default:
            throw NetworkException(message, statusCode);
        }
      case DioExceptionType.cancel:
        throw NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        throw NoInternetException();
      default:
        throw NetworkException('Unknown network error');
    }
  }
}
