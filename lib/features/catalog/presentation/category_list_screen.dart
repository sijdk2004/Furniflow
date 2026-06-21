import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../master_data/presentation/master_data_provider.dart';
import '../../master_data/data/master_data_repository.dart';
import '../../master_data/domain/master_data_model.dart';
import '../../../core/routing/permission_guard.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  void _deleteCategory(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(masterDataRepositoryProvider).deleteMasterData('product_categories', id);
        ref.refresh(masterDataProvider('product_categories'));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(masterDataProvider('product_categories'));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Product Categories', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/catalog'),
                    icon: const Icon(Icons.inventory),
                    label: const Text('Back to Products'),
                  ),
                  const SizedBox(width: 16),
                  PermissionGuard(
                    requiredPermission: 'CAT.CAT_CAT.CREATE',
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/catalog/categories/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: asyncData.when(
                data: (data) => _buildDataTable(context, ref, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<MasterDataModel> data) {
    if (data.isEmpty) return const Center(child: Text('No categories found.'));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: data.map((item) => DataRow(
            cells: [
              DataCell(Text(item.code)),
              DataCell(Text(item.name)),
              DataCell(Text(item.description ?? '-')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PermissionGuard(
                      requiredPermission: 'CAT.CAT_CAT.VIEW',
                      child: IconButton(icon: const Icon(Icons.visibility, color: Colors.grey), onPressed: () => context.go('/catalog/categories/view/${item.id}')),
                    ),
                    PermissionGuard(
                      requiredPermission: 'CAT.CAT_CAT.UPDATE',
                      child: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => context.go('/catalog/categories/edit/${item.id}')),
                    ),
                    PermissionGuard(
                      requiredPermission: 'CAT.CAT_CAT.DELETE',
                      child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(context, ref, item.id)),
                    ),
                  ],
                ),
              ),
            ]
          )).toList(),
        ),
      ),
    );
  }
}
