class MasterDataModel {
  final String id;
  final String type;
  final String code;
  final String name;
  final String description;
  final int sortOrder;
  final bool isActive;

  MasterDataModel({
    required this.id,
    required this.type,
    required this.code,
    required this.name,
    this.description = '',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory MasterDataModel.fromJson(Map<String, dynamic> json) {
    return MasterDataModel(
      id: json['id'],
      type: json['type'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'code': code,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
