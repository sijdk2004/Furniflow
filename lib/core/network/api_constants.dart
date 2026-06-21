class ApiConstants {
  // Headers
  static const String authHeader = 'Authorization';
  static const String tenantIdHeader = 'X-Tenant-ID';
  static const String orgIdHeader = 'X-Organization-ID';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
}
