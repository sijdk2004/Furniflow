class QuotationItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const QuotationItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class Quotation {
  final String id;
  final String customerName;
  final String company;
  final String status; // Draft, Sent, Approved, Rejected
  final DateTime dateCreated;
  final DateTime validUntil;
  final List<QuotationItem> items;
  final double discount;

  const Quotation({
    required this.id,
    required this.customerName,
    required this.company,
    required this.status,
    required this.dateCreated,
    required this.validUntil,
    required this.items,
    this.discount = 0.0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal - discount;
}

final List<Quotation> mockQuotations = [
  Quotation(
    id: 'QT-2024-001',
    customerName: 'Sarah Jenkins',
    company: 'Jenkins Interiors',
    status: 'Approved',
    dateCreated: DateTime.now().subtract(const Duration(days: 5)),
    validUntil: DateTime.now().add(const Duration(days: 10)),
    items: const [
      QuotationItem(productId: 'P001', productName: 'Executive Oak Desk', quantity: 10, unitPrice: 450.0),
      QuotationItem(productId: 'P002', productName: 'Ergonomic Mesh Chair', quantity: 10, unitPrice: 199.99),
    ],
    discount: 500.0,
  ),
  Quotation(
    id: 'QT-2024-002',
    customerName: 'David Miller',
    company: 'Miller Design Studio',
    status: 'Sent',
    dateCreated: DateTime.now().subtract(const Duration(days: 2)),
    validUntil: DateTime.now().add(const Duration(days: 13)),
    items: const [
      QuotationItem(productId: 'P003', productName: 'Modern Dining Table', quantity: 5, unitPrice: 899.0),
    ],
  ),
  Quotation(
    id: 'QT-2024-003',
    customerName: 'Michael Chang',
    company: 'Chang Furniture',
    status: 'Draft',
    dateCreated: DateTime.now(),
    validUntil: DateTime.now().add(const Duration(days: 15)),
    items: const [
      QuotationItem(productId: 'P005', productName: 'King Size Platform Bed', quantity: 20, unitPrice: 1200.0),
      QuotationItem(productId: 'P004', productName: 'Minimalist Wardrobe', quantity: 20, unitPrice: 650.0),
    ],
    discount: 2000.0,
  ),
];
