class BomItem {
  final String id;
  final String bomId;
  final String componentId;
  final double quantity;
  final String uomId;
  final double unitCost;
  final double totalCost;
  final Map<String, dynamic>? component;
  final Map<String, dynamic>? uom;

  BomItem({
    required this.id,
    required this.bomId,
    required this.componentId,
    required this.quantity,
    required this.uomId,
    required this.unitCost,
    required this.totalCost,
    this.component,
    this.uom,
  });

  factory BomItem.fromJson(Map<String, dynamic> json) {
    return BomItem(
      id: json['id'] ?? '',
      bomId: json['bom_id'] ?? '',
      componentId: json['component_id'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      uomId: json['uom_id'] ?? '',
      unitCost: (json['unit_cost'] ?? 0).toDouble(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      component: json['component'],
      uom: json['uom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bom_id': bomId,
      'component_id': componentId,
      'quantity': quantity,
      'uom_id': uomId,
      'unit_cost': unitCost,
      'total_cost': totalCost,
    };
  }
}

class Bom {
  final String id;
  final String tenantId;
  final String productId;
  final int versionNumber;
  final bool activeVersion;
  final String status;
  final double materialCost;
  final double laborCost;
  final double overheadCost;
  final double totalCost;
  final DateTime createdOn;
  final String? remarks;
  final List<BomItem> items;
  final Map<String, dynamic>? product;

  Bom({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.versionNumber,
    required this.activeVersion,
    required this.status,
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.totalCost,
    required this.createdOn,
    this.remarks,
    required this.items,
    this.product,
  });

  factory Bom.fromJson(Map<String, dynamic> json) {
    return Bom(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      productId: json['product_id'] ?? '',
      versionNumber: json['version_number'] ?? 1,
      activeVersion: json['active_version'] ?? false,
      status: json['status'] ?? 'Draft',
      materialCost: (json['material_cost'] ?? 0).toDouble(),
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      overheadCost: (json['overhead_cost'] ?? 0).toDouble(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      createdOn: json['created_on'] != null ? DateTime.parse(json['created_on']) : DateTime.now(),
      remarks: json['remarks'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => BomItem.fromJson(item))
              .toList() ??
          [],
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'product_id': productId,
      'version_number': versionNumber,
      'active_version': activeVersion,
      'status': status,
      'material_cost': materialCost,
      'labor_cost': laborCost,
      'overhead_cost': overheadCost,
      'total_cost': totalCost,
      'created_on': createdOn.toIso8601String(),
      'remarks': remarks,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
