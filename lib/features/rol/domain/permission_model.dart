class PermissionModel {
  final String id;
  final String permissionCode;
  final String moduleCode;
  final String screenCode;
  final String actionType;
  final String? displayName;
  final String? description;
  final bool isActive;

  PermissionModel({
    required this.id,
    required this.permissionCode,
    required this.moduleCode,
    required this.screenCode,
    required this.actionType,
    this.displayName,
    this.description,
    this.isActive = true,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] ?? '',
      permissionCode: json['permission_code'] ?? '',
      moduleCode: json['module_code'] ?? '',
      screenCode: json['screen_code'] ?? '',
      actionType: json['action_type'] ?? '',
      displayName: json['display_name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permission_code': permissionCode,
      'module_code': moduleCode,
      'screen_code': screenCode,
      'action_type': actionType,
      'display_name': displayName,
      'description': description,
      'is_active': isActive,
    };
  }
}
