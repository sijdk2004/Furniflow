import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/sales_order_model.dart';

class SalesOrderNotifier extends Notifier<List<SalesOrder>> {
  @override
  List<SalesOrder> build() => mockSalesOrders;

  void addSalesOrder(SalesOrder order) {
    state = [...state, order];
  }

  void updateStatus(String id, String newStatus) {
    state = [
      for (final order in state)
        if (order.id == id)
          SalesOrder(
            id: order.id,
            customerName: order.customerName,
            status: newStatus,
            orderDate: order.orderDate,
            estimatedDelivery: order.estimatedDelivery,
            items: order.items,
            paymentStatus: order.paymentStatus,
          )
        else
          order,
    ];
  }
}

final salesOrdersProvider = NotifierProvider<SalesOrderNotifier, List<SalesOrder>>(() {
  return SalesOrderNotifier();
});
