import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../master_data/data/master_data_repository.dart';
import '../../master_data/presentation/master_data_provider.dart';
import '../../master_data/domain/master_data_model.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const CategoryFormScreen({super.key, this.id});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sortCtrl = TextEditingController(text: '0');
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await ref.read(masterDataRepositoryProvider).getMasterData('product_categories');
      final item = list.firstWhere((e) => e.id == widget.id);
      _codeCtrl.text = item.code;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description ?? '';
      _sortCtrl.text = item.sortOrder.toString();
      _isActive = item.isActive;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final payload = {
      'code': _codeCtrl.text,
      'name': _nameCtrl.text,
      'description': _descCtrl.text.isEmpty ? null : _descCtrl.text,
      'sort_order': int.tryParse(_sortCtrl.text) ?? 0,
      'is_active': _isActive,
    };
    try {
      if (widget.id == null) {
        await ref.read(masterDataRepositoryProvider).createMasterData('product_categories', payload);
      } else {
        await ref.read(masterDataRepositoryProvider).updateMasterData('product_categories', widget.id!, payload);
      }
      if (mounted) {
        ref.refresh(masterDataProvider('product_categories'));
        context.go('/catalog/categories');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Category' : 'Edit Category')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(labelText: 'Category Code *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Category Name *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sortCtrl,
                    decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Is Active'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => context.go('/catalog/categories'), child: const Text('Cancel')),
                      const SizedBox(width: 16),
                      ElevatedButton(onPressed: _submit, child: const Text('Save')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
