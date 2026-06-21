import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/quotation_model.dart';

class QuotationNotifier extends Notifier<List<Quotation>> {
  @override
  List<Quotation> build() => mockQuotations;

  void addQuotation(Quotation quotation) {
    state = [...state, quotation];
  }

  void updateStatus(String id, String newStatus) {
    state = [
      for (final q in state)
        if (q.id == id)
          Quotation(
            id: q.id,
            customerName: q.customerName,
            company: q.company,
            status: newStatus,
            dateCreated: q.dateCreated,
            validUntil: q.validUntil,
            items: q.items,
            discount: q.discount,
          )
        else
          q,
    ];
  }
}

final quotationsProvider = NotifierProvider<QuotationNotifier, List<Quotation>>(() {
  return QuotationNotifier();
});
