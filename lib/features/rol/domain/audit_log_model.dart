class AuditLogModel {
  final String id;
  final String action;
  final String? entityName;
  final String? entityId;
  final String details;
  final String createdOn;
  final String? userId;

  AuditLogModel({
    required this.id,
    required this.action,
    this.entityName,
    this.entityId,
    required this.details,
    required this.createdOn,
    this.userId,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      entityName: json['entity_name'],
      entityId: json['entity_id'],
      details: json['details'] ?? '',
      createdOn: json['created_on'] ?? '',
      userId: json['user_id'],
    );
  }
}
