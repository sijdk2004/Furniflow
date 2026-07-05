import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../data/bom_provider.dart';
import '../../catalog/data/product_api_provider.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../catalog/domain/product_model_api.dart';
import '../../master_data/domain/master_data_model.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';

class BomFormScreen extends ConsumerStatefulWidget {
  final String? bomId;

  const BomFormScreen({super.key, this.bomId});

  @override
  ConsumerState<BomFormScreen> createState() => _BomFormScreenState();
}

class _BomFormScreenState extends ConsumerState<BomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProductId;
  final _materialCostController = TextEditingController(text: '0');
  final _laborCostController = TextEditingController(text: '0');
  final _overheadCostController = TextEditingController(text: '0');
  final _remarksController = TextEditingController();

  final List<Map<String, dynamic>> _items = [];

  List<ProductModel> _products = [];
  List<MasterDataModel> _uoms = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prods = await ref.read(productsApiProvider.future);
      final uomRes = await ref.read(apiClientProvider).get('/v1/system/masters/units_of_measure');
      final uomsList = (uomRes.data['data'] as List).map((e) => MasterDataModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          _products = prods;
          _uoms = uomsList;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _addItem() {
    setState(() {
      _items.add({
        'component_id': null,
        'quantity': 1.0,
        'uom_id': null,
        'unit_cost': 0.0,
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one component')));
      return;
    }
    
    // Check if items are fully filled and valid
    for (var i = 0; i < _items.length; i++) {
      if (_items[i]['component_id'] == null || _items[i]['uom_id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please complete item #${i + 1}')));
        return;
      }
      if (_items[i]['component_id'] == _selectedProductId) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('A product cannot be a component of itself (Item #${i + 1}). Circular Dependency!'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    try {
      final data = {
        'product_id': _selectedProductId,
        'material_cost': double.tryParse(_materialCostController.text) ?? 0,
        'labor_cost': double.tryParse(_laborCostController.text) ?? 0,
        'overhead_cost': double.tryParse(_overheadCostController.text) ?? 0,
        'remarks': _remarksController.text,
        'items': _items.map((e) => {
          'component_id': e['component_id'],
          'quantity': e['quantity'],
          'uom_id': e['uom_id'],
          'unit_cost': e['unit_cost'],
        }).toList(),
      };

      await ref.read(bomProvider.notifier).createBom(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('BOM saved successfully')));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving BOM: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Bill of Materials'),
        actions: [
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(LucideIcons.save, size: 18),
            label: const Text('Save BOM'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BOM Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      SearchableDropdown<ProductModel>(
                        label: 'Target Product',
                        isRequired: true,
                        items: _products,
                        itemAsString: (p) => '${p.productCode} - ${p.productName}',
                        selectedItem: _products.where((p) => p.id == _selectedProductId).firstOrNull,
                        onChanged: (val) => setState(() => _selectedProductId = val?.id),
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _laborCostController,
                              decoration: const InputDecoration(labelText: 'Labor Cost'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _overheadCostController,
                              decoration: const InputDecoration(labelText: 'Overhead Cost'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _remarksController,
                        decoration: const InputDecoration(labelText: 'Remarks / Notes'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Components (Materials)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          OutlinedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Add Component'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('No components added yet', style: TextStyle(color: Colors.grey))),
                        ),
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SearchableDropdown<ProductModel>(
                                  label: 'Component ${idx + 1}',
                                  isRequired: true,
                                  items: _products,
                                  itemAsString: (p) => '${p.productCode} - ${p.productName}',
                                  selectedItem: _products.where((p) => p.id == item['component_id']).firstOrNull,
                                  onChanged: (val) => setState(() => item['component_id'] = val?.id),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: item['quantity'].toString(),
                                  decoration: const InputDecoration(labelText: 'Qty *', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => item['quantity'] = double.tryParse(val) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: SearchableDropdown<MasterDataModel>(
                                  label: 'UOM',
                                  isRequired: true,
                                  items: _uoms,
                                  itemAsString: (u) => u.code,
                                  selectedItem: _uoms.where((u) => u.id == item['uom_id']).firstOrNull,
                                  onChanged: (val) => setState(() => item['uom_id'] = val?.id),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: item['unit_cost'].toString(),
                                  decoration: const InputDecoration(labelText: 'Unit Cost', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => item['unit_cost'] = double.tryParse(val) ?? 0,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.red),
                                onPressed: () => _removeItem(idx),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
