import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/sales_order_provider.dart';
import '../../../core/utils/shared_dialogs.dart';

class SalesOrderEditScreen extends ConsumerStatefulWidget {
  final String orderId;

  const SalesOrderEditScreen({super.key, required this.orderId});

  @override
  ConsumerState<SalesOrderEditScreen> createState() => _SalesOrderEditScreenState();
}

class _SalesOrderEditScreenState extends ConsumerState<SalesOrderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  DateTime? _expectedDeliveryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final order = await ref.read(salesOrderProvider.notifier).getSalesOrderById(widget.orderId);
    setState(() {
      _remarksController.text = order.remarks ?? '';
      _expectedDeliveryDate = order.expectedDeliveryDate;
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final order = await ref.read(salesOrderProvider.notifier).getSalesOrderById(widget.orderId);
      
      await ref.read(salesOrderProvider.notifier).updateSalesOrder(
        widget.orderId,
        expectedDeliveryDate: _expectedDeliveryDate,
        remarks: _remarksController.text,
        discount: order.discount,
        items: order.items, // Keep items unchanged
      );
      if (mounted) {
        context.pop();
        SharedDialogs.showSuccessSnackbar(context, 'Sales Order updated successfully');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Sales Order: ${widget.orderId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.save, size: 18),
              label: const Text('Save Changes'),
            ),
          ),
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Logistics Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _expectedDeliveryDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _expectedDeliveryDate = date);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Expected Delivery Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(LucideIcons.calendar),
                                ),
                                child: Text(
                                  _expectedDeliveryDate != null
                                      ? FormatHelper.formatDate(_expectedDeliveryDate!)
                                      : 'Select Date',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: const SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Internal Remarks / Delivery Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
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
