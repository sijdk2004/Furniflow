class DeliveryItem {
  final String productName;
  final int quantity;

  const DeliveryItem({
    required this.productName,
    required this.quantity,
  });
}

class Delivery {
  final String id;
  final String salesOrderId;
  final String customerName;
  final String address;
  final DateTime deliveryDate;
  final String driverName;
  final String status; // Scheduled, In Transit, Delivered
  final List<DeliveryItem> items;

  const Delivery({
    required this.id,
    required this.salesOrderId,
    required this.customerName,
    required this.address,
    required this.deliveryDate,
    required this.driverName,
    required this.status,
    required this.items,
  });
}

final List<Delivery> mockDeliveries = [
  Delivery(
    id: 'DEL-2026-001',
    salesOrderId: 'SO-24-1029',
    customerName: 'Sarah Jenkins',
    address: '123 Pine Lane, Springfield',
    deliveryDate: DateTime.now().add(const Duration(days: 2)),
    driverName: 'Mike Johnson',
    status: 'Scheduled',
    items: const [
      DeliveryItem(productName: 'Executive Oak Desk', quantity: 5),
      DeliveryItem(productName: 'Ergonomic Mesh Chair', quantity: 5),
    ],
  ),
  Delivery(
    id: 'DEL-2026-002',
    salesOrderId: 'SO-24-1030',
    customerName: 'Michael Chang',
    address: '456 Elm St, Metro City',
    deliveryDate: DateTime.now().add(const Duration(hours: 4)),
    driverName: 'David Lee',
    status: 'In Transit',
    items: const [
      DeliveryItem(productName: 'Modern Dining Table', quantity: 12),
    ],
  ),
  Delivery(
    id: 'DEL-2026-003',
    salesOrderId: 'SO-24-1032',
    customerName: 'Emma Watson',
    address: '789 Oak Ave, Rivertown',
    deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
    driverName: 'Sarah Smith',
    status: 'Delivered',
    items: const [
      DeliveryItem(productName: 'Floating TV Unit', quantity: 1),
    ],
  ),
];
