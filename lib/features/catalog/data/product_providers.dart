import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_model.dart';

class ProductNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => mockProducts;

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = [
      for (final p in state)
        if (p.id == product.id) product else p,
    ];
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final productsProvider = NotifierProvider<ProductNotifier, List<Product>>(() {
  return ProductNotifier();
});

final productsCountProvider = Provider<int>((ref) {
  return ref.watch(productsProvider).length;
});
