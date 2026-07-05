class ApiConstants {
  // Headers
  static const String authHeader = 'Authorization';
  static const String tenantIdHeader = 'X-Tenant-ID';
  static const String orgIdHeader = 'X-Organization-ID';

  // Endpoints
  static const String loginEndpoint = '/v1/auth/login';
  static const String refreshEndpoint = '/v1/auth/refresh';
}
