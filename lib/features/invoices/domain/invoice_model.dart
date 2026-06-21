class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class Invoice {
  final String id;
  final String salesOrderId;
  final String customerName;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status; // Draft, Sent, Paid, Overdue
  final List<InvoiceItem> items;

  const Invoice({
    required this.id,
    required this.salesOrderId,
    required this.customerName,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.items,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.1; // 10% tax for example
  double get total => subtotal + tax;
}

final List<Invoice> mockInvoices = [
  Invoice(
    id: 'INV-2026-101',
    salesOrderId: 'SO-24-1029',
    customerName: 'Sarah Jenkins',
    issueDate: DateTime.now().subtract(const Duration(days: 3)),
    dueDate: DateTime.now().add(const Duration(days: 27)),
    status: 'Sent',
    items: const [
      InvoiceItem(description: 'Executive Oak Desk', quantity: 5, unitPrice: 450.0),
      InvoiceItem(description: 'Ergonomic Mesh Chair', quantity: 5, unitPrice: 199.99),
    ],
  ),
  Invoice(
    id: 'INV-2026-102',
    salesOrderId: 'SO-24-1030',
    customerName: 'Michael Chang',
    issueDate: DateTime.now().subtract(const Duration(days: 45)),
    dueDate: DateTime.now().subtract(const Duration(days: 15)),
    status: 'Overdue',
    items: const [
      InvoiceItem(description: 'Modern Dining Table', quantity: 12, unitPrice: 899.0),
    ],
  ),
  Invoice(
    id: 'INV-2026-103',
    salesOrderId: 'SO-24-1032',
    customerName: 'Emma Watson',
    issueDate: DateTime.now().subtract(const Duration(days: 30)),
    dueDate: DateTime.now(),
    status: 'Paid',
    items: const [
      InvoiceItem(description: 'Floating TV Unit', quantity: 1, unitPrice: 340.0),
    ],
  ),
  Invoice(
    id: 'INV-2026-104',
    salesOrderId: 'SO-24-1033',
    customerName: 'David Miller',
    issueDate: DateTime.now(),
    dueDate: DateTime.now().add(const Duration(days: 30)),
    status: 'Draft',
    items: const [
      InvoiceItem(description: 'Minimalist Wardrobe', quantity: 2, unitPrice: 650.0),
    ],
  ),
];
