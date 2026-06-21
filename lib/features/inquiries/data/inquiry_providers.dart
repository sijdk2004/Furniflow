import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inquiry_model.dart';

class InquiryNotifier extends Notifier<List<Inquiry>> {
  @override
  List<Inquiry> build() => mockInquiries;

  void addInquiry(Inquiry inquiry) {
    state = [...state, inquiry];
  }

  void updateInquiry(Inquiry inquiry) {
    state = [
      for (final i in state)
        if (i.id == inquiry.id) inquiry else i,
    ];
  }

  void updateStatus(String id, String newStatus) {
    state = [
      for (final i in state)
        if (i.id == id)
          Inquiry(
            id: i.id,
            customerName: i.customerName,
            company: i.company,
            subject: i.subject,
            status: newStatus,
            dateReceived: i.dateReceived,
            estimatedValue: i.estimatedValue,
          )
        else
          i,
    ];
  }
}

final inquiriesProvider = NotifierProvider<InquiryNotifier, List<Inquiry>>(() {
  return InquiryNotifier();
});
