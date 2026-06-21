import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/job_order_model.dart';

class JobOrderNotifier extends Notifier<List<JobOrder>> {
  @override
  List<JobOrder> build() => mockJobOrders;

  void updateStage(String id, String newStage) {
    state = [
      for (final jo in state)
        if (jo.id == id)
          JobOrder(
            id: jo.id,
            productionOrderId: jo.productionOrderId,
            componentName: jo.componentName,
            stage: newStage,
            assignedTo: jo.assignedTo,
            priority: jo.priority,
            dueDate: jo.dueDate,
          )
        else
          jo,
    ];
  }
}

final jobOrdersProvider = NotifierProvider<JobOrderNotifier, List<JobOrder>>(() {
  return JobOrderNotifier();
});
