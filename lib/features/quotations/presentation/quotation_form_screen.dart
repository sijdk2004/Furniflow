import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../data/quotation_api_provider.dart';
import '../../customers/data/customer_provider.dart';
import '../../catalog/data/product_api_provider.dart';
import '../../../core/utils/shared_dialogs.dart';
class QuotationFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const QuotationFormScreen({super.key, this.id});

  @override
  ConsumerState<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationItemState {
  String? productId;
  int quantity = 1;
  double unitPrice = 0.0;
  _QuotationItemState({this.productId, this.quantity = 1, this.unitPrice = 0.0});
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCustomer;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  final _discountCtrl = TextEditingController(text: '0.0');
  final _taxCtrl = TextEditingController(text: '0.0');
  final _notesCtrl = TextEditingController();

  List<_QuotationItemState> _items = [_QuotationItemState()];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final q = await ref.read(quotationApiRepositoryProvider).getQuotation(widget.id!);
      _selectedCustomer = q.customerId;
      _validUntil = q.validUntil;
      _discountCtrl.text = q.discount.toString();
      _taxCtrl.text = q.tax.toString();
      _notesCtrl.text = q.notes ?? '';
      
      _items = q.items.map((i) => _QuotationItemState(
        productId: i.productId,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
      )).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // validate items
    for (var item in _items) {
      if (item.productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select products for all items.')));
        return;
      }
    }

    setState(() => _isLoading = true);
    
    final payload = {
      'customer_id': _selectedCustomer,
      'valid_until': '${_validUntil.toUtc().toIso8601String().split('T')[0]}T00:00:00Z',
      'discount': double.tryParse(_discountCtrl.text) ?? 0.0,
      'tax': double.tryParse(_taxCtrl.text) ?? 0.0,
      'notes': _notesCtrl.text,
      'items': _items.map((i) => {
        'product_id': i.productId,
        'quantity': i.quantity,
        'unit_price': i.unitPrice,
      }).toList(),
    };

    try {
      if (widget.id == null) {
        await ref.read(quotationApiRepositoryProvider).createQuotation(payload);
      } else {
        await ref.read(quotationApiRepositoryProvider).updateQuotation(widget.id!, payload);
      }
      if (mounted) {
        ref.refresh(quotationsApiProvider);
        SharedDialogs.showSuccessSnackbar(context, 'Quotation saved successfully');
        context.go('/quotations');
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

    final theme = Theme.of(context);
    final customersFuture = ref.watch(customersProvider);
    final productsFuture = ref.watch(productsApiProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Quotation' : 'Edit Quotation')),
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
                      const Text('General Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: customersFuture.when(
                              data: (data) => DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder()),
                                value: _selectedCustomer,
                                items: data.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                                onChanged: (val) => setState(() => _selectedCustomer = val),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                              loading: () => DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder()),
                                items: const [],
                                onChanged: null,
                                hint: const Text('Loading...'),
                              ),
                              error: (e, s) => DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder(), errorText: 'Failed to load'),
                                items: const [],
                                onChanged: null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context, 
                                  initialDate: _validUntil, 
                                  firstDate: DateTime.now(), 
                                  lastDate: DateTime.now().add(const Duration(days: 365))
                                );
                                if (d != null) setState(() => _validUntil = d);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Valid Until *', border: OutlineInputBorder()),
                                child: Text(DateFormat('yyyy-MM-dd').format(_validUntil)),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      ..._items.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: productsFuture.when(
                                  data: (data) => DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                                    value: item.productId,
                                    items: data.map((p) => DropdownMenuItem(value: p.id, child: Text(p.productName))).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        item.productId = val;
                                        // Auto fill price
                                        final product = data.firstWhere((p) => p.id == val);
                                        item.unitPrice = product.basePrice;
                                      });
                                    },
                                  ),
                                  loading: () => DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                                    items: const [],
                                    onChanged: null,
                                    hint: const Text('Loading...'),
                                  ),
                                  error: (e, s) => DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), errorText: 'Failed to load'),
                                    items: const [],
                                    onChanged: null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => setState(() => item.quantity = int.tryParse(v) ?? 1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  key: ValueKey('price_${index}_${item.productId}'), // re-render when product changes
                                  initialValue: item.unitPrice.toString(),
                                  decoration: const InputDecoration(labelText: 'Unit Price', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => setState(() => item.unitPrice = double.tryParse(v) ?? 0.0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                                  child: Text('\$${NumberFormat('#,##0.00').format(item.quantity * item.unitPrice)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash, color: Colors.red),
                                onPressed: () {
                                  if (_items.length > 1) {
                                    setState(() => _items.removeAt(index));
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () => setState(() => _items.add(_QuotationItemState())),
                        icon: const Icon(LucideIcons.plus),
                        label: const Text('Add Item'),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Totals & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _notesCtrl,
                              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _discountCtrl,
                                  decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder(), prefixText: '\$'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState((){}),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _taxCtrl,
                                  decoration: const InputDecoration(labelText: 'Tax', border: OutlineInputBorder(), prefixText: '\$'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState((){}),
                                ),
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    double subtotal = _items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice));
                                    double discount = double.tryParse(_discountCtrl.text) ?? 0.0;
                                    double tax = double.tryParse(_taxCtrl.text) ?? 0.0;
                                    double total = subtotal - discount + tax;
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      color: theme.colorScheme.primaryContainer,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimaryContainer)),
                                          Text('\$${NumberFormat('#,##0.00').format(total)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimaryContainer)),
                                        ],
                                      ),
                                    );
                                  }
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => context.go('/quotations'), child: const Text('Cancel')),
                  const SizedBox(width: 16),
                  ElevatedButton(onPressed: _submit, child: const Text('Save Quotation')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
