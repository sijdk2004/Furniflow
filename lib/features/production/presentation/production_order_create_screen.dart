import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../data/production_order_provider.dart';
import '../../catalog/data/product_api_provider.dart';
import '../../sales_orders/data/sales_order_provider.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';
import '../../catalog/domain/product_model_api.dart';
import '../../sales_orders/domain/sales_order_model.dart';

class ProductionOrderCreateScreen extends ConsumerStatefulWidget {
  const ProductionOrderCreateScreen({super.key});

  @override
  ConsumerState<ProductionOrderCreateScreen> createState() => _ProductionOrderCreateScreenState();
}

class _ProductionOrderCreateScreenState extends ConsumerState<ProductionOrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSalesOrderId;
  String? _selectedProductId;
  int _quantity = 1;
  String _remarks = '';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product to manufacture')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'sales_order_id': _selectedSalesOrderId,
        'product_id': _selectedProductId,
        'quantity': _quantity,
        'remarks': _remarks,
      };

      await ref.read(productionOrderProvider.notifier).createOrder(payload);
      if (mounted) {
        context.pop();
        SharedDialogs.showSuccessSnackbar(context, 'Production Order created successfully');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsApiProvider);
    final salesOrdersAsync = ref.watch(salesOrderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Production Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          
                          // Sales Order Selection (Optional)
                          salesOrdersAsync.when(
                            data: (orders) {
                              return SearchableDropdown<SalesOrder>(
                                label: 'Link to Sales Order (Optional)',
                                items: orders,
                                itemAsString: (o) => 'SO-${o.id.length > 8 ? o.id.substring(0,8) : o.id} - ${o.customer?['name'] ?? 'Unknown'}',
                                selectedItem: orders.where((o) => o.id == _selectedSalesOrderId).firstOrNull,
                                onChanged: (val) => setState(() => _selectedSalesOrderId = val?.id),
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, st) => Text('Error loading Sales Orders: $e', style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 20),

                          // Product Selection
                          productsAsync.when(
                            data: (products) {
                              return SearchableDropdown<ProductModel>(
                                label: 'Product to Manufacture',
                                isRequired: true,
                                items: products,
                                itemAsString: (p) => '${p.productCode} - ${p.productName}',
                                selectedItem: products.where((p) => p.id == _selectedProductId).firstOrNull,
                                onChanged: (val) => setState(() => _selectedProductId = val?.id),
                                validator: (val) => val == null ? 'Please select a product' : null,
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, st) => Text('Error loading Products: $e', style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 20),

                          // Quantity
                          TextFormField(
                            initialValue: '1',
                            decoration: const InputDecoration(
                              labelText: 'Production Quantity *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(LucideIcons.hash, size: 20),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Quantity required';
                              if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Must be > 0';
                              return null;
                            },
                            onSaved: (val) => _quantity = int.parse(val!),
                          ),
                          const SizedBox(height: 20),

                          // Remarks
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Production Remarks',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(LucideIcons.messageSquare, size: 20),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            onSaved: (val) => _remarks = val ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(LucideIcons.save, size: 18),
                        label: Text(_isSubmitting ? 'Creating...' : 'Create Production Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
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
