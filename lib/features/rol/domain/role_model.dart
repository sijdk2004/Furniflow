class RoleModel {
  final String id;
  final String roleCode;
  final String roleName;
  final bool isSystemRole;

  RoleModel({
    required this.id,
    required this.roleCode,
    required this.roleName,
    this.isSystemRole = false,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? '',
      roleCode: json['role_code'] ?? '',
      roleName: json['role_name'] ?? '',
      isSystemRole: json['is_system_role'] ?? false,
    );
  }
}
