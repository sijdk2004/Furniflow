class QuotationItemModel {
  final String? id;
  final String productId;
  final String? productName;
  final String? productCode;
  final int quantity;
  final double unitPrice;
  final double? totalPrice;

  QuotationItemModel({
    this.id,
    required this.productId,
    this.productName,
    this.productCode,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
  });

  factory QuotationItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return QuotationItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: product?['product_name'] as String?,
      productCode: product?['product_code'] as String?,
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: json['total_price'] != null ? (json['total_price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class QuotationModel {
  final String id;
  final String customerId;
  final String status;
  final DateTime dateCreated;
  final DateTime validUntil;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? notes;
  final List<QuotationItemModel> items;
  final Map<String, dynamic>? customer; // Attached via relation

  QuotationModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.dateCreated,
    required this.validUntil,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.notes,
    required this.items,
    this.customer,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<QuotationItemModel> itemsList = list.map((i) => QuotationItemModel.fromJson(i)).toList();

    return QuotationModel(
      id: json['id'],
      customerId: json['customer_id'],
      status: json['status'],
      dateCreated: DateTime.parse(json['date_created']),
      validUntil: DateTime.parse(json['valid_until']),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'],
      items: itemsList,
      customer: json['customer'],
    );
  }
}
