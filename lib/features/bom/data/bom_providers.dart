import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bom_model.dart';

class BomNotifier extends Notifier<List<Bom>> {
  @override
  List<Bom> build() => mockBoms;
}

final bomsProvider = NotifierProvider<BomNotifier, List<Bom>>(() {
  return BomNotifier();
});
