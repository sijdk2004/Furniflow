class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String type; // Raw Material, Finished Good
  final double quantity;
  final String unit;
  final double minStockLevel;
  final String location;
  final double unitValue;

  const InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.minStockLevel,
    required this.location,
    required this.unitValue,
  });

  bool get isLowStock => quantity <= minStockLevel;
  double get totalValue => quantity * unitValue;
}

final List<InventoryItem> mockInventory = [
  // Raw Materials
  const InventoryItem(
    id: 'INV-M-001',
    sku: 'MAT-OAK-001',
    name: 'Solid Oak Panel',
    type: 'Raw Material',
    quantity: 120,
    unit: 'sqm',
    minStockLevel: 50,
    location: 'Warehouse A - Zone 1',
    unitValue: 45.0,
  ),
  const InventoryItem(
    id: 'INV-M-002',
    sku: 'MAT-SCW-050',
    name: 'Steel Screws 50mm',
    type: 'Raw Material',
    quantity: 5000,
    unit: 'pcs',
    minStockLevel: 10000,
    location: 'Warehouse B - Shelf 4',
    unitValue: 0.05,
  ),
  const InventoryItem(
    id: 'INV-M-003',
    sku: 'MAT-FAB-MSH',
    name: 'Mesh Fabric (Black)',
    type: 'Raw Material',
    quantity: 25,
    unit: 'roll',
    minStockLevel: 30,
    location: 'Warehouse A - Zone 2',
    unitValue: 120.0,
  ),
  
  // Finished Goods
  const InventoryItem(
    id: 'INV-F-001',
    sku: 'DSK-OAK-001',
    name: 'Executive Oak Desk',
    type: 'Finished Good',
    quantity: 24,
    unit: 'pcs',
    minStockLevel: 10,
    location: 'Showroom & Warehouse C',
    unitValue: 280.0,
  ),
  const InventoryItem(
    id: 'INV-F-002',
    sku: 'CHR-MSH-002',
    name: 'Ergonomic Mesh Chair',
    type: 'Finished Good',
    quantity: 150,
    unit: 'pcs',
    minStockLevel: 50,
    location: 'Warehouse C - Aisle 1',
    unitValue: 85.0,
  ),
  const InventoryItem(
    id: 'INV-F-003',
    sku: 'DT-MOD-003',
    name: 'Modern Dining Table',
    type: 'Finished Good',
    quantity: 4,
    unit: 'pcs',
    minStockLevel: 5,
    location: 'Warehouse C - Aisle 3',
    unitValue: 450.0,
  ),
];
