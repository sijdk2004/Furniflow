import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../master_data/data/master_data_repository.dart';
import '../../master_data/domain/master_data_model.dart';

class CategoryViewScreen extends ConsumerStatefulWidget {
  final String id;
  const CategoryViewScreen({super.key, required this.id});

  @override
  ConsumerState<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends ConsumerState<CategoryViewScreen> {
  bool _isLoading = true;
  MasterDataModel? _category;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ref.read(masterDataRepositoryProvider).getMasterData('product_categories');
      _category = list.firstWhere((e) => e.id == widget.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_category == null) return const Scaffold(body: Center(child: Text('Not found')));

    return Scaffold(
      appBar: AppBar(title: const Text('Category Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Code:', _category!.code),
                _buildRow('Name:', _category!.name),
                _buildRow('Description:', _category!.description ?? '-'),
                _buildRow('Sort Order:', _category!.sortOrder.toString()),
                _buildRow('Status:', _category!.isActive ? 'Active' : 'Inactive'),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.go('/catalog/categories'), child: const Text('Back to List')),
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
