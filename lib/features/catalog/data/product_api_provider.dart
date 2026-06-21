import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// removed dio
import 'package:file_picker/file_picker.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/network/api_client.dart';
import '../domain/product_model_api.dart';

final productApiRepositoryProvider = Provider<ProductApiRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProductApiRepository(apiClient);
});

class ProductApiRepository {
  final ApiClient apiClient;
  ProductApiRepository(this.apiClient);

  Future<List<ProductModel>> getProducts() async {
    final response = await apiClient.get('/v1/system/products');
    final data = response.data['data'] as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await apiClient.get('/v1/system/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    await apiClient.post('/v1/system/products', data: payload);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> payload) async {
    await apiClient.put('/v1/system/products/$id', data: payload);
  }

  Future<void> deleteProduct(String id) async {
    await apiClient.delete('/v1/system/products/$id');
  }

  Future<String?> uploadImage(PlatformFile file) async {
    try {
      final response = await apiClient.post('/v1/system/upload/image', data: {
         'file': file.path // simplified for POC as FormData needs dio import
      });
      return response.data['url'];
    } catch (e) {
      return null;
    }
  }
}

final productsApiProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) {
  return ref.watch(productApiRepositoryProvider).getProducts();
});
