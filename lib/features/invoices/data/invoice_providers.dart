import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/invoice_model.dart';

class InvoiceNotifier extends Notifier<List<Invoice>> {
  @override
  List<Invoice> build() => mockInvoices;

  void updateStatus(String id, String newStatus) {
    state = [
      for (final invoice in state)
        if (invoice.id == id)
          Invoice(
            id: invoice.id,
            salesOrderId: invoice.salesOrderId,
            customerName: invoice.customerName,
            issueDate: invoice.issueDate,
            dueDate: invoice.dueDate,
            status: newStatus,
            items: invoice.items,
          )
        else
          invoice,
    ];
  }

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }
}

final invoicesProvider = NotifierProvider<InvoiceNotifier, List<Invoice>>(() {
  return InvoiceNotifier();
});
