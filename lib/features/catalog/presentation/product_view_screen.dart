import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/product_api_provider.dart';
import '../domain/product_model_api.dart';

class ProductViewScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductViewScreen({super.key, required this.id});

  @override
  ConsumerState<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends ConsumerState<ProductViewScreen> {
  bool _isLoading = true;
  ProductModel? _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _product = await ref.read(productApiRepositoryProvider).getProduct(widget.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_product == null) return const Scaffold(body: Center(child: Text('Not found')));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: _product!.imageUrl != null ? DecorationImage(image: NetworkImage(_product!.imageUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: _product!.imageUrl == null ? const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)) : null,
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Product Code:', _product!.productCode),
                      _buildRow('Name:', _product!.productName),
                      _buildRow('Category:', _product!.category?.name ?? '-'),
                      _buildRow('Wood Type:', _product!.woodType?.name ?? '-'),
                      _buildRow('UOM:', _product!.uom?.name ?? '-'),
                      _buildRow('Base Price:', '\$${_product!.basePrice.toStringAsFixed(2)}'),
                      _buildRow('Description:', _product!.description ?? '-'),
                      _buildRow('Status:', _product!.isActive ? 'Active' : 'Inactive'),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: () => context.go('/catalog'), child: const Text('Back to List')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(val)),
        ],
      ),
    );
  }
}
