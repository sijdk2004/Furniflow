class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stockQuantity;
  final String status; // Active, Draft, Archived
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.status,
    required this.imageUrl,
  });
}

final List<Product> mockProducts = [
  const Product(
    id: 'P001',
    name: 'Executive Oak Desk',
    sku: 'DSK-OAK-001',
    category: 'Office Desk',
    price: 450.00,
    stockQuantity: 24,
    status: 'Active',
    imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=300&q=80',
  ),
  const Product(
    id: 'P002',
    name: 'Ergonomic Mesh Chair',
    sku: 'CHR-MSH-002',
    category: 'Chair',
    price: 199.99,
    stockQuantity: 150,
    status: 'Active',
    imageUrl: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&w=300&q=80',
  ),
  const Product(
    id: 'P003',
    name: 'Modern Dining Table',
    sku: 'DT-MOD-003',
    category: 'Dining Table',
    price: 899.00,
    stockQuantity: 12,
    status: 'Active',
    imageUrl: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?auto=format&fit=crop&w=300&q=80',
  ),
  const Product(
    id: 'P004',
    name: 'Minimalist Wardrobe',
    sku: 'WD-MIN-004',
    category: 'Wardrobe',
    price: 650.00,
    stockQuantity: 5,
    status: 'Active',
    imageUrl: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=300&q=80',
  ),
  const Product(
    id: 'P005',
    name: 'King Size Platform Bed',
    sku: 'BD-KNG-005',
    category: 'Bed',
    price: 1200.00,
    stockQuantity: 8,
    status: 'Active',
    imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=300&q=80',
  ),
  const Product(
    id: 'P006',
    name: 'Floating TV Unit',
    sku: 'TV-FLT-006',
    category: 'TV Unit',
    price: 340.00,
    stockQuantity: 0,
    status: 'Draft',
    imageUrl: 'https://images.unsplash.com/photo-1601366533287-5ee4c763ae4e?auto=format&fit=crop&w=300&q=80',
  ),
];
