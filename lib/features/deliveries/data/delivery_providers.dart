import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/delivery_model.dart';

class DeliveryNotifier extends Notifier<List<Delivery>> {
  @override
  List<Delivery> build() => mockDeliveries;

  void updateStatus(String id, String newStatus) {
    state = [
      for (final delivery in state)
        if (delivery.id == id)
          Delivery(
            id: delivery.id,
            salesOrderId: delivery.salesOrderId,
            customerName: delivery.customerName,
            address: delivery.address,
            deliveryDate: delivery.deliveryDate,
            driverName: delivery.driverName,
            status: newStatus,
            items: delivery.items,
          )
        else
          delivery,
    ];
  }
}

final deliveriesProvider = NotifierProvider<DeliveryNotifier, List<Delivery>>(() {
  return DeliveryNotifier();
});
