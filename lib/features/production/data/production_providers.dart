import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/production_model.dart';

class ProductionNotifier extends Notifier<List<ProductionOrder>> {
  @override
  List<ProductionOrder> build() => mockProductionOrders;

  void updateStatus(String id, String newStatus) {
    state = [
      for (final order in state)
        if (order.id == id)
          ProductionOrder(
            id: order.id,
            productName: order.productName,
            quantity: order.quantity,
            startDate: order.startDate,
            endDate: order.endDate,
            progress: order.progress,
            status: newStatus,
          )
        else
          order,
    ];
  }
}

final productionProvider = NotifierProvider<ProductionNotifier, List<ProductionOrder>>(() {
  return ProductionNotifier();
});
