import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/theme/colors.dart';
import '../data/delivery_provider.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';
import '../../production/data/production_order_provider.dart';
import '../../../core/utils/shared_dialogs.dart';

class DeliveryCreateScreen extends ConsumerStatefulWidget {
  const DeliveryCreateScreen({super.key});

  @override
  ConsumerState<DeliveryCreateScreen> createState() => _DeliveryCreateScreenState();
}

class _DeliveryCreateScreenState extends ConsumerState<DeliveryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProductionOrderId;
  DateTime _expectedDeliveryDate = DateTime.now().add(const Duration(days: 3));
  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProductionOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a production order and fill required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(deliveryRepositoryProvider);
      await repo.createDelivery({
        'production_order_id': _selectedProductionOrderId,
        'expected_delivery_date': _expectedDeliveryDate.toUtc().toIso8601String(),
        'assigned_vehicle': _vehicleController.text.isNotEmpty ? _vehicleController.text : null,
        'assigned_driver': _driverController.text.isNotEmpty ? _driverController.text : null,
        'delivery_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      });

      if (mounted) {
        ref.invalidate(deliveriesProvider);
        context.pop();
        SharedDialogs.showSuccessSnackbar(context, 'Delivery scheduled successfully');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedProductionOrdersState = ref.watch(completedProductionOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Schedule Delivery', style: TextStyle(color: AppColors.textPrimaryDark)),
        backgroundColor: AppColors.surfaceDark,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              color: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Production Order Selection
                      completedProductionOrdersState.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Text('Error loading orders: $err', style: const TextStyle(color: Colors.red)),
                        data: (orders) {
                          return SearchableDropdown<ProductionOrder>(
                            label: 'Production Order',
                            isRequired: true,
                            items: orders,
                            itemAsString: (order) {
                              final displayId = order.id.toString().length > 8 ? order.id.toString().substring(0, 8) : order.id.toString();
                              return 'PO-$displayId - ${order.status}';
                            },
                            selectedItem: orders.where((o) => o.id == _selectedProductionOrderId).firstOrNull,
                            onChanged: (val) => setState(() => _selectedProductionOrderId = val?.id),
                            validator: (val) => val == null ? 'Please select an order' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Expected Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expectedDeliveryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _expectedDeliveryDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expected Delivery Date *',
                            labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                          ),
                          child: Text(
                            FormatHelper.formatDate(_expectedDeliveryDate),
                            style: const TextStyle(color: AppColors.textPrimaryDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Vehicle & Driver
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vehicleController,
                              style: const TextStyle(color: AppColors.textPrimaryDark),
                              decoration: const InputDecoration(
                                labelText: 'Assigned Vehicle',
                                labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _driverController,
                              style: const TextStyle(color: AppColors.textPrimaryDark),
                              decoration: const InputDecoration(
                                labelText: 'Assigned Driver',
                                labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: AppColors.textPrimaryDark),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Notes',
                          labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSubmitting ? null : () => context.pop(),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Schedule Delivery', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
