import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/network/api_client.dart';
import '../domain/quotation_model_api.dart';

final quotationApiRepositoryProvider = Provider<QuotationApiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuotationApiRepository(apiClient);
});

final quotationsApiProvider = FutureProvider<List<QuotationModel>>((ref) async {
  final repo = ref.watch(quotationApiRepositoryProvider);
  return repo.getQuotations();
});

class QuotationApiRepository {
  final ApiClient _apiClient;
  
  QuotationApiRepository(this._apiClient);

  Future<List<QuotationModel>> getQuotations() async {
    final response = await _apiClient.get('/v1/system/quotations');
    final data = response.data['data'] as List;
    return data.map((json) => QuotationModel.fromJson(json)).toList();
  }

  Future<QuotationModel> getQuotation(String id) async {
    final response = await _apiClient.get('/v1/system/quotations/$id');
    return QuotationModel.fromJson(response.data['data']);
  }

  Future<void> createQuotation(Map<String, dynamic> payload) async {
    await _apiClient.post('/v1/system/quotations', data: payload);
  }

  Future<void> updateQuotation(String id, Map<String, dynamic> payload) async {
    await _apiClient.put('/v1/system/quotations/$id', data: payload);
  }

  Future<void> updateStatus(String id, String status) async {
    await _apiClient.patch('/v1/system/quotations/$id/status', data: {'status': status});
  }

  Future<void> deleteQuotation(String id) async {
    await _apiClient.delete('/v1/system/quotations/$id');
  }
}
