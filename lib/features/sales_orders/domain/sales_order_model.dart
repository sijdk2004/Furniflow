class SalesOrder {
  final String id;
  final String? orderNumber;
  final String customerId;
  final String? quotationId;
  final String? salesPerson;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String? remarks;
  final List<SalesOrderItem> items;
  final Map<String, dynamic>? customer;

  SalesOrder({
    required this.id,
    this.orderNumber,
    required this.customerId,
    this.quotationId,
    this.salesPerson,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.totalAmount,
    this.remarks,
    required this.items,
    this.customer,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      customerId: json['customer_id'],
      quotationId: json['quotation_id'],
      salesPerson: json['sales_person'],
      status: json['status'],
      orderDate: DateTime.parse(json['order_date']),
      expectedDeliveryDate: json['expected_delivery_date'] != null 
          ? DateTime.parse(json['expected_delivery_date']) 
          : null,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      remarks: json['remarks'],
      items: (json['items'] as List?)
              ?.map((i) => SalesOrderItem.fromJson(i))
              .toList() ??
          [],
      customer: json['customer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'quotation_id': quotationId,
      'sales_person': salesPerson,
      'status': status,
      'order_date': orderDate.toIso8601String(),
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'remarks': remarks,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class SalesOrderItem {
  final String id;
  final String salesOrderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic>? product;

  SalesOrderItem({
    required this.id,
    required this.salesOrderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.product,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      id: json['id'],
      salesOrderId: json['sales_order_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_order_id': salesOrderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
