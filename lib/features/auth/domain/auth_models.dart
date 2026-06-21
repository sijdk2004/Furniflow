class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String tenantId;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.tenantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      tenantId: json['tenant_id'] ?? '',
    );
  }
}

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final List<String> permissions;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.permissions,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}
