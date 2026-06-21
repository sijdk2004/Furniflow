class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'NetworkException: $message (Status Code: $statusCode)';
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message, 401);
}

class ForbiddenException extends NetworkException {
  ForbiddenException([String message = 'Forbidden']) : super(message, 403);
}

class NotFoundException extends NetworkException {
  NotFoundException([String message = 'Not Found']) : super(message, 404);
}

class ServerException extends NetworkException {
  ServerException([String message = 'Internal Server Error']) : super(message, 500);
}

class TimeoutException extends NetworkException {
  TimeoutException([String message = 'Connection Timeout']) : super(message);
}

class NoInternetException extends NetworkException {
  NoInternetException([String message = 'No Internet Connection']) : super(message);
}
