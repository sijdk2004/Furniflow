import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/master_data_model.dart';

class SelectedMasterDataTypeNotifier extends Notifier<String> {
  @override
  String build() => 'wood_types';

  void setType(String type) {
    state = type;
  }
}

final selectedMasterDataTypeProvider = NotifierProvider<SelectedMasterDataTypeNotifier, String>(
  SelectedMasterDataTypeNotifier.new,
);

final masterDataProvider = AsyncNotifierProvider<MasterDataNotifier, List<MasterDataModel>>(
  MasterDataNotifier.new,
);

class MasterDataNotifier extends AsyncNotifier<List<MasterDataModel>> {
  late ApiClient _apiClient;

  @override
  Future<List<MasterDataModel>> build() async {
    _apiClient = ref.watch(apiClientProvider);
    final type = ref.watch(selectedMasterDataTypeProvider);
    return _fetchMasterData(type);
  }

  Future<List<MasterDataModel>> _fetchMasterData(String type) async {
    final response = await _apiClient.get('/v1/system/masters/$type');
    final data = response.data['data'] as List;
    return data.map((json) => MasterDataModel.fromJson(json)).toList();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    try {
      final type = ref.read(selectedMasterDataTypeProvider);
      final records = await _fetchMasterData(type);
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createRecord(Map<String, dynamic> data) async {
    final type = ref.read(selectedMasterDataTypeProvider);
    await _apiClient.post('/v1/system/masters/$type', data: data);
    await reload();
  }

  Future<void> updateRecord(String id, Map<String, dynamic> data) async {
    final type = ref.read(selectedMasterDataTypeProvider);
    await _apiClient.put('/v1/system/masters/$type/$id', data: data);
    await reload();
  }

  Future<void> deleteRecord(String id) async {
    final type = ref.read(selectedMasterDataTypeProvider);
    await _apiClient.delete('/v1/system/masters/$type/$id');
    await reload();
  }
}
