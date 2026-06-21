import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/master_data_model.dart';
import '../data/master_data_repository.dart';

final masterDataProvider = FutureProvider.family<List<MasterDataModel>, String>((ref, type) async {
  final repo = ref.watch(masterDataRepositoryProvider);
  return repo.getMasterData(type);
});
