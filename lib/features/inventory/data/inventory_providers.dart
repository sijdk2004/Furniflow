import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inventory_model.dart';

class InventoryNotifier extends Notifier<List<InventoryItem>> {
  @override
  List<InventoryItem> build() => mockInventory;
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<InventoryItem>>(() {
  return InventoryNotifier();
});
