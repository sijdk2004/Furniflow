class ProductionOrder {
  final String id;
  final String productName;
  final int quantity;
  final String status; // Planned, Released, In Progress, Completed
  final DateTime startDate;
  final DateTime endDate;
  final double progress; // 0.0 to 1.0

  const ProductionOrder({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });
}

final List<ProductionOrder> mockProductionOrders = [
  ProductionOrder(
    id: 'PRD-2024-089',
    productName: 'Executive Oak Desk',
    quantity: 50,
    status: 'In Progress',
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    progress: 0.45,
  ),
  ProductionOrder(
    id: 'PRD-2024-090',
    productName: 'Ergonomic Mesh Chair',
    quantity: 200,
    status: 'Planned',
    startDate: DateTime.now().add(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 14)),
    progress: 0.0,
  ),
  ProductionOrder(
    id: 'PRD-2024-091',
    productName: 'Modern Dining Table',
    quantity: 20,
    status: 'Released',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    progress: 0.1,
  ),
  ProductionOrder(
    id: 'PRD-2024-080',
    productName: 'Minimalist Wardrobe',
    quantity: 15,
    status: 'Completed',
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().subtract(const Duration(days: 1)),
    progress: 1.0,
  ),
];
