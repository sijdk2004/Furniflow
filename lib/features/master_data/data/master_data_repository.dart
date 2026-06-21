import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/master_data_model.dart';

class MasterDataRepository {
  final ApiClient _apiClient;

  MasterDataRepository(this._apiClient);

  Future<List<MasterDataModel>> getMasterData(String type) async {
    final response = await _apiClient.get('/v1/system/masters/$type');
    final dataList = response.data['data'] as List;
    return dataList.map((e) => MasterDataModel.fromJson(e)).toList();
  }

  Future<void> createMasterData(String type, Map<String, dynamic> data) async {
    await _apiClient.post('/v1/system/masters/$type', data: data);
  }

  Future<void> updateMasterData(String type, String id, Map<String, dynamic> data) async {
    await _apiClient.put('/v1/system/masters/$type/$id', data: data);
  }

  Future<void> deleteMasterData(String type, String id) async {
    await _apiClient.delete('/v1/system/masters/$type/$id');
  }
}

final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepository(ref.watch(apiClientProvider));
});
