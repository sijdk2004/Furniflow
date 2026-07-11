import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';
import '../data/quotation_api_provider.dart';
import '../../customers/data/customer_provider.dart';
import '../../catalog/data/product_api_provider.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../catalog/domain/product_model_api.dart';
import '../../customers/domain/customer_model.dart';
import '../../usr/data/users_provider.dart';
import '../../usr/domain/user_model.dart';
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
  final _advanceAmountCtrl = TextEditingController(text: '0.0');
  final _notesCtrl = TextEditingController();
  final _quotationNumberCtrl = TextEditingController();
  String? _selectedSalesPerson;

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
      _advanceAmountCtrl.text = q.advanceAmount.toString();
      _notesCtrl.text = q.notes ?? '';
      _quotationNumberCtrl.text = q.quotationNumber ?? '';
      _selectedSalesPerson = q.salesPerson;
      
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
      'advance_amount': double.tryParse(_advanceAmountCtrl.text) ?? 0.0,
      'notes': _notesCtrl.text,
      'quotation_number': _quotationNumberCtrl.text.isEmpty ? null : _quotationNumberCtrl.text,
      'sales_person': _selectedSalesPerson,
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
                            child: TextFormField(
                              controller: _quotationNumberCtrl,
                              decoration: const InputDecoration(labelText: 'Quotation Number (Optional)', border: OutlineInputBorder(), hintText: 'e.g. No. 373'),
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
                                child: Text(FormatHelper.formatDate(_validUntil)),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: customersFuture.when(
                              data: (data) => SearchableDropdown<CustomerModel>(
                                label: 'Customer',
                                isRequired: true,
                                items: data,
                                itemAsString: (c) => c.name,
                                selectedItem: data.where((c) => c.id == _selectedCustomer).firstOrNull,
                                onChanged: (val) => setState(() => _selectedCustomer = val?.id),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                              loading: () => TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder(), hintText: 'Loading...'),
                              ),
                              error: (e, s) => TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder(), errorText: 'Failed to load'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ref.watch(usersProvider).when(
                              data: (users) => SearchableDropdown<UserModel>(
                                label: 'Sales Person',
                                items: users,
                                itemAsString: (u) => '${u.firstName} ${u.lastName ?? ''}'.trim(),
                                selectedItem: users.where((u) => '${u.firstName} ${u.lastName ?? ''}'.trim() == _selectedSalesPerson).firstOrNull,
                                onChanged: (val) {
                                  setState(() => _selectedSalesPerson = val != null ? '${val.firstName} ${val.lastName ?? ''}'.trim() : null);
                                },
                              ),
                              loading: () => TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(labelText: 'Sales Person', border: OutlineInputBorder(), hintText: 'Loading...'),
                              ),
                              error: (e, s) => TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(labelText: 'Sales Person', border: OutlineInputBorder(), errorText: 'Failed to load'),
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
                                  data: (data) => SearchableDropdown<ProductModel>(
                                    label: 'Product',
                                    items: data,
                                    itemAsString: (p) => p.productName,
                                    selectedItem: data.where((p) => p.id == item.productId).firstOrNull,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          item.productId = val.id;
                                          item.unitPrice = val.basePrice;
                                        });
                                      }
                                    },
                                  ),
                                  loading: () => TextFormField(
                                    enabled: false,
                                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), hintText: 'Loading...'),
                                  ),
                                  error: (e, s) => TextFormField(
                                    enabled: false,
                                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), errorText: 'Failed to load'),
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
                                  child: Text(FormatHelper.formatCurrency(item.quantity * item.unitPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                  decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder(), prefixText: '₹'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState((){}),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _taxCtrl,
                                  decoration: const InputDecoration(labelText: 'Tax', border: OutlineInputBorder(), prefixText: '₹'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState((){}),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _advanceAmountCtrl,
                                  decoration: const InputDecoration(labelText: 'Advance Amount', border: OutlineInputBorder(), prefixText: '₹'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState((){}),
                                ),
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    double subtotal = _items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice));
                                    double discount = double.tryParse(_discountCtrl.text) ?? 0.0;
                                    double tax = double.tryParse(_taxCtrl.text) ?? 0.0;
                                    double advanceAmount = double.tryParse(_advanceAmountCtrl.text) ?? 0.0;
                                    double total = subtotal - discount + tax;
                                    double balance = total - advanceAmount;
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      color: theme.colorScheme.primaryContainer,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Grand Total', style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimaryContainer)),
                                              Text(FormatHelper.formatCurrency(total), style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimaryContainer)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Balance Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimaryContainer)),
                                              Text(FormatHelper.formatCurrency(balance), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimaryContainer)),
                                            ],
                                          ),
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
