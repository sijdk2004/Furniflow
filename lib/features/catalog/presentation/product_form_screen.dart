import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../master_data/presentation/master_data_provider.dart';
import '../data/product_api_provider.dart';
import '../../master_data/data/master_data_repository.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const ProductFormScreen({super.key, this.id});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0.0');

  String? _selectedCategory;
  String? _selectedWoodType;
  String? _selectedUOM;
  String? _imageUrl;
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
      final item = await ref.read(productApiRepositoryProvider).getProduct(widget.id!);
      _codeCtrl.text = item.productCode;
      _nameCtrl.text = item.productName;
      _descCtrl.text = item.description ?? '';
      _priceCtrl.text = item.basePrice.toString();
      _selectedCategory = item.category?.id;
      _selectedWoodType = item.woodType?.id;
      _selectedUOM = item.uom?.id;
      _imageUrl = item.imageUrl;
      _isActive = item.isActive;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final url = await ref.read(productApiRepositoryProvider).uploadImage(result.files.first);
        if (url != null) {
          setState(() => _imageUrl = url);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final payload = {
      'product_code': _codeCtrl.text,
      'product_name': _nameCtrl.text,
      'description': _descCtrl.text.isEmpty ? null : _descCtrl.text,
      'base_price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'category_id': _selectedCategory,
      'wood_type_id': _selectedWoodType,
      'uom_id': _selectedUOM,
      'image_url': _imageUrl,
      'is_active': _isActive,
    };
    try {
      if (widget.id == null) {
        await ref.read(productApiRepositoryProvider).createProduct(payload);
      } else {
        await ref.read(productApiRepositoryProvider).updateProduct(widget.id!, payload);
      }
      if (mounted) {
        ref.refresh(productsApiProvider);
        context.go('/catalog');
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

    final catFuture = ref.watch(masterDataProvider('product_categories'));
    final woodFuture = ref.watch(masterDataProvider('wood_types'));
    final uomFuture = ref.watch(masterDataProvider('units_of_measure'));

    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Product' : 'Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 150, height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: _imageUrl != null ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover) : null,
                            ),
                            child: _imageUrl == null ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)) : null,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Product Code *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                              const SizedBox(height: 16),
                              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    catFuture.when(
                      data: (data) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        value: _selectedCategory,
                        items: data.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => const Text('Error'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: woodFuture.when(
                            data: (data) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Wood Type', border: OutlineInputBorder()),
                              value: _selectedWoodType,
                              items: data.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                              onChanged: (val) => setState(() => _selectedWoodType = val),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, s) => const Text('Error'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: uomFuture.when(
                            data: (data) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'UOM', border: OutlineInputBorder()),
                              value: _selectedUOM,
                              items: data.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                              onChanged: (val) => setState(() => _selectedUOM = val),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, s) => const Text('Error'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Base Price', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
                    const SizedBox(height: 16),
                    SwitchListTile(title: const Text('Is Active'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => context.go('/catalog'), child: const Text('Cancel')),
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
      ),
    );
  }
}
