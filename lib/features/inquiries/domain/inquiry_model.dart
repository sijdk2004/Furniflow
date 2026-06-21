class Inquiry {
  final String id;
  final String customerName;
  final String company;
  final String subject;
  final String status; // New, Reviewed, Qualified, Waiting, Closed
  final DateTime dateReceived;
  final double estimatedValue;

  const Inquiry({
    required this.id,
    required this.customerName,
    required this.company,
    required this.subject,
    required this.status,
    required this.dateReceived,
    required this.estimatedValue,
  });
}

final List<Inquiry> mockInquiries = [
  Inquiry(
    id: 'INQ-1001',
    customerName: 'Sarah Jenkins',
    company: 'Jenkins Interiors',
    subject: 'Bulk order for Executive Desks',
    status: 'New',
    dateReceived: DateTime.now().subtract(const Duration(hours: 2)),
    estimatedValue: 15000.00,
  ),
  Inquiry(
    id: 'INQ-1002',
    customerName: 'Michael Chang',
    company: 'Chang Furniture',
    subject: 'Custom Dimensions for Dining Tables',
    status: 'Reviewed',
    dateReceived: DateTime.now().subtract(const Duration(days: 1)),
    estimatedValue: 8500.00,
  ),
  Inquiry(
    id: 'INQ-1003',
    customerName: 'Emma Watson',
    company: 'Individual',
    subject: 'Pricing for Minimalist Wardrobe',
    status: 'Qualified',
    dateReceived: DateTime.now().subtract(const Duration(days: 2)),
    estimatedValue: 650.00,
  ),
  Inquiry(
    id: 'INQ-1004',
    customerName: 'David Miller',
    company: 'Miller Design Studio',
    subject: 'Hotel Lobby Furniture Package',
    status: 'Waiting',
    dateReceived: DateTime.now().subtract(const Duration(days: 3)),
    estimatedValue: 45000.00,
  ),
  Inquiry(
    id: 'INQ-1005',
    customerName: 'Robert Fox',
    company: 'Fox Real Estate',
    subject: 'Staging Furniture Inquiry',
    status: 'Closed',
    dateReceived: DateTime.now().subtract(const Duration(days: 10)),
    estimatedValue: 12000.00,
  ),
];
