class JobOrder {
  final String id;
  final String productionOrderId;
  final String componentName;
  final String stage; // Cutting, Assembly, Sanding, Polishing, Finishing
  final String assignedTo;
  final String priority; // High, Medium, Low
  final DateTime dueDate;

  const JobOrder({
    required this.id,
    required this.productionOrderId,
    required this.componentName,
    required this.stage,
    required this.assignedTo,
    required this.priority,
    required this.dueDate,
  });
}

final List<JobOrder> mockJobOrders = [
  JobOrder(
    id: 'JO-8921',
    productionOrderId: 'PRD-2024-089',
    componentName: 'Oak Table Top Panels',
    stage: 'Cutting',
    assignedTo: 'Sawyer Smith',
    priority: 'High',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  JobOrder(
    id: 'JO-8922',
    productionOrderId: 'PRD-2024-089',
    componentName: 'Oak Legs',
    stage: 'Sanding',
    assignedTo: 'Woody Allen',
    priority: 'Medium',
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),
  JobOrder(
    id: 'JO-8923',
    productionOrderId: 'PRD-2024-089',
    componentName: 'Drawers',
    stage: 'Assembly',
    assignedTo: 'Mark Builder',
    priority: 'Low',
    dueDate: DateTime.now().add(const Duration(days: 3)),
  ),
  JobOrder(
    id: 'JO-8924',
    productionOrderId: 'PRD-2024-091',
    componentName: 'Dining Table Surface',
    stage: 'Polishing',
    assignedTo: 'Sarah Shines',
    priority: 'High',
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  JobOrder(
    id: 'JO-8925',
    productionOrderId: 'PRD-2024-091',
    componentName: 'Table Base',
    stage: 'Finishing',
    assignedTo: 'Finley Coates',
    priority: 'Medium',
    dueDate: DateTime.now(),
  ),
];
